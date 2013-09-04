require 'jruby-parser'
require 'rubylm/metamodel'
require 'emf_jruby'

java_import org.jrubyparser.ast.Node
java_import org.jrubyparser.ast.ArrayNode
java_import org.jrubyparser.ast.ListNode
java_import org.jrubyparser.ast.BlockPassNode
java_import org.jrubyparser.ast.ArgsNode
java_import org.jrubyparser.ast.IterNode
java_import org.jrubyparser.ast.SymbolNode
java_import org.jrubyparser.ast.ArrayNode

java_import org.jrubyparser.util.StaticAnalyzerHelper

module RubyMM

class << self
	attr_accessor :skip_unknown_node
end

def self.parse_file(path)
	content = IO.read(path)
	self.parse(content)
end

class ParsingError < Exception
 	attr_reader :node

 	def initialize(node,msg)
 		@node = node
 		@msg = msg
 	end

 	def to_s
 		"#{@msg}, start line: #{@node.position.start_line}"
 	end

end

class UnknownNodeType < ParsingError

 	def initialize(node,where=nil)
 		super(node,"UnknownNodeType: type=#{node.node_type.name} , where: #{where}")
 	end

end

def self.assert_node_type(node,type)
	raise ParsingError.new(node,"AssertionFailed: #{type} expected but #{node.node_type.name} found") unless node.node_type.name==type
end


def self.parse(code)
	tree = JRubyParser.parse(code, {:version=>JRubyParser::Compat::RUBY2_0})
	tree_to_model(tree)
end

def self.tree_to_model(tree)
	unless tree.node_type.name=='ROOTNODE' 
		raise 'Root expected'
	end
	node_to_model tree.body
end

def self.body_node_to_contents(body_node,container_node)
	body = node_to_model(body_node)
	if body
		if body.is_a? RubyMM::Block	
			body.contents.each do |el|
				container_node.contents = container_node.contents << el 
			end
		else
			container_node.contents = container_node.contents << body
		end
	end
end

def self.get_var_name_depending_on_parser_version(node,prefix_size=1)
	if node.respond_to? :lexical_name # depends on the version...
		return node.name
 	else
 		return node.name[prefix_size..-1]
 	end
 end

def self.my_args_flattener(args_node)
	if args_node.node_type.name=='ARGSPUSHNODE'
		res = my_args_flattener(args_node.firstNode)
		res << node_to_model(args_node.secondNode)
		res
	elsif args_node.node_type.name=='ARGSCATNODE'
		res = my_args_flattener(args_node.firstNode)
		if args_node.secondNode.is_a?(ArrayNode)
			res.concat(my_args_flattener(args_node.secondNode))
		else
			res << RubyMM.splat(node_to_model(args_node.secondNode))
		end
		res
	elsif args_node.is_a? ListNode
		res = []
		for i in 0..(args_node.size-1) 
			res << node_to_model(args_node.get i)
		end
		res		
	elsif args_node.node_type.name=='SPLATNODE'
		res = []
		res << node_to_model(args_node)
		res
	else
		raise "Unknown: #{args_node.node_type.name} at #{args_node.position}, parent #{args_node.parent}"
	end
end

def self.node_to_model(node,parent_model=nil)
	return nil if node==nil
	#puts "#{node} #{node.node_type.name}"
	case node.node_type.name
	when 'NEWLINENODE'
		node_to_model node.next_node

	##
	## Literals
	##
	when 'FLOATNODE'
		model = RubyMM::FloatLiteral.new
		model.value = node.value
		model
	when 'FIXNUMNODE'
		model = RubyMM::IntLiteral.new
		model.value = node.value
		model
	when 'STRNODE'
		model = RubyMM::StringLiteral.new
		model.value = node.value
		model.dynamic = false
		model
	when 'DSTRNODE'
		model = RubyMM::StringLiteral.new
		#model.value = node.value
		model.dynamic = true
		for i in 0..(node.size-1)
			model.pieces = model.pieces << node_to_model(node.get i)
		end
		model
	when 'DREGEXPNODE'
		model = RubyMM::RegExpLiteral.new
		#model.value = node.value
		model.dynamic = true
		for i in 0..(node.size-1)
			model.pieces = model.pieces << node_to_model(node.get i)
		end
		model
	when 'NILNODE'
		begin
			implicit_nil = Java::OrgJrubyparserAst::NilImplicitNode
		rescue
			implicit_nil = nil # apparently the class was removed...
		end
		if implicit_nil && (node.is_a? Java::OrgJrubyparserAst::NilImplicitNode)
			return nil
		else
			#puts "NIL for #{node}"
			RubyMM::NilLiteral.new
		end
 	when 'FALSENODE'
 		model = RubyMM::BooleanLiteral.new
 		model.value = false
 		model
 	when 'TRUENODE'
 		model = RubyMM::BooleanLiteral.new
 		model.value = true
 		model
 	when 'REGEXPNODE'
 		model = RubyMM::RegExpLiteral.new
 		model.value = node.value
 		model

 	###
 	### Variable accesses
 	###
 	when 'LOCALVARNODE'
 		model = RubyMM::LocalVarAccess.new
 		model.name = node.name
 		model
 	when 'DVARNODE'
 		model = RubyMM::BlockVarAccess.new
 		model.name = node.name
 		model
 	when 'GLOBALVARNODE'
 		model = RubyMM::GlobalVarAccess.new
 		model.name = get_var_name_depending_on_parser_version(node)
 		model
 	when 'CLASSVARNODE'
 		model = RubyMM::ClassVarAccess.new
 		model.name = get_var_name_depending_on_parser_version(node,2)
 		model
 	when 'INSTVARNODE'
 		RubyMM::InstanceVarAccess.build get_var_name_depending_on_parser_version(node) 	

 	###
 	### Variable Assignments
 	###
  	when 'LOCALASGNNODE'
 		model = RubyMM::LocalVarAssignment.new
 		model.name_assigned = node.name
 		model.value = node_to_model(node.value)
 		model		
  	when 'DASGNNODE'
 		model = RubyMM::BlockVarAssignment.new
 		model.name_assigned = node.name
 		model.value = node_to_model(node.value)
 		model	 		
 	when 'GLOBALASGNNODE'
 		model = RubyMM::GlobalVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node)
 		model.value = node_to_model(node.value)
 		model 		
 	when 'CLASSVARASGNNODE'
 		model = RubyMM::ClassVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node,2)
 		model.value = node_to_model(node.value)
 		model 		
 	when 'INSTASGNNODE'
 		model = RubyMM::InstanceVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node)
 		model.value = node_to_model(node.value)
 		model

 	###
 	### Other assignments
 	###

 	when 'OPELEMENTASGNNODE'
 		model = RubyMM::ElementOperationAssignment.new
 		model.container = node_to_model(node.receiver)
 		model.element = node_to_model(node.args[0])
 		model.value = node_to_model(node.value)
 		model.operator = node.operator_name
 		model
 	when 'ATTRASSIGNNODE'
 		model = RubyMM::ElementAssignment.new
 		model.container = node_to_model(node.receiver)
 		if node.args # apparently it can be null...
 			model.element = node_to_model(node.args[0])
 			model.value = node_to_model(node.args[1])
 		end
 		model
 	when 'OPASGNORNODE'
 		model = RubyMM::OrAssignment.new
 		# assigned : from access to variable
 		# value    : from Assignment to value 		
 		model.assigned = node_to_model(node.first)
 		model.value = node_to_model(node.second).value
 		model
 	when 'MULTIPLEASGNNODE'
 		# TODO consider asterisk
 		model = RubyMM::MultipleAssignment.new
 		if node.pre
 			for i in 0..(node.pre.count-1)
 				model.assignments = model.assignments << node_to_model(node.pre.get(i))
 			end
 		end
 		values_model = node_to_model(node.value)
 		if values_model.respond_to? :values
 			values_model.values.each {|x| model.values = model.values << x}
 		else
 			model.values = model.values << values_model
 		end
 		# TODO consider rest and post!
 		model
 	when 'MULTIPLEASGN19NODE'
  		# TODO consider asterisk
 		model = RubyMM::MultipleAssignment.new
 		if node.pre
 			for i in 0..(node.pre.count-1)
 				model.assignments = model.assignments << node_to_model(node.pre.get(i))
 			end
 		end
 		values_model = node_to_model(node.value)
 		if values_model.respond_to? :values
 			values_model.values.each {|x| model.values = model.values << x}
 		else
 			model.values = model.values << values_model
 		end
 		# TODO consider rest and post!
 		model
 	when 'OPASGNNODE'
 		model = RubyMM::OperatorAssignment.new
 		model.value = node_to_model(node.valueNode)
 		model.container = node_to_model(node.receiverNode)
 		model.element_name = node.variable_name
 		model.operator_name = node.operator_name
    	model

 	###
 	### Constants
 	###

 	when 'CONSTDECLNODE'
 		model = RubyMM::ConstantDecl.new
 		model.name = node.name
 		model.value = node_to_model(node.value)
 		model

 	###
 	### Statements
 	###

 	when 'ALIASNODE'
 		model = RubyMM::AliasStatement.new
 		model.old_name = node_to_model(node.oldName)
 		model.new_name = node_to_model(node.newName)
 		model
 	when 'CASENODE'
 		model = RubyMM::CaseStatement.new
 		for ci in 0..(node.cases.count-1)
 			c = node.cases[ci]
 			model.when_clauses = model.when_clauses << node_to_model(c)
 		end
 		model.else_body = node_to_model(node.else)
 		model
 	when 'WHENNODE'
 		model = RubyMM::WhenClause.new
 		model.body = node_to_model(node.body)
 		model.condition = node_to_model(node.expression)
 		model
 	when 'UNDEFNODE'
 		model = RubyMM::UndefStatement.new
 		model.name = node_to_model(node.name)
 		model
 	when 'WHILENODE'
 		model = RubyMM::WhileStatement.new
 		model.body = node_to_model(node.body)
 		model.condition = node_to_model(node.condition)
 		model
 	when 'BREAKNODE'
 		RubyMM::BreakStatement.new
 	when 'UNTILNODE'
 		model = RubyMM::UntilStatement.new
 		model.body = node_to_model(node.body)
 		model.condition = node_to_model(node.condition)
 		model 		
 	when 'RESCUENODE'
 		model = RubyMM::RescueStatement.new
 		model.body = node_to_model(node.body)
 		model.value = node_to_model(node.rescueNode.body)
 		model

 	###
 	### The rest
 	###

 	when 'NTHREFNODE'
 		RubyMM::NthGroupReference.build(node.matchNumber)
 	when 'YIELDNODE'
 		RubyMM::YieldStatement.new
	when 'NEXTNODE'
 		RubyMM::NextStatement.new 		
 	when 'COLON3NODE'
 		model = RubyMM::GlobalScopeReference.new
 		model.name = node.name
 		model
 	when 'DOTNODE'
 		model = RubyMM::Range.new
 		model.lower = node_to_model(node.beginNode)
 		model.upper = node_to_model(node.endNode)
 		model
 	when 'MATCH2NODE'
 		model = RubyMM::RegexTryer.new
 		model.checked_value = node_to_model(node.value)
 		model.regex = node_to_model(node.receiver)
 		model 		
 	when 'MATCH3NODE'
 		model = RubyMM::RegexMatcher.new
 		model.checked_value = node_to_model(node.value)
 		model.regex = node_to_model(node.receiver)
 		model
 	when 'LITERALNODE'
 		model = RubyMM::LiteralReference.new
 		model.value = node.name
 		model
 	when 'SELFNODE'
 		model = RubyMM::Self.new
 		model
 	when 'ZSUPERNODE'
 		model = RubyMM::CallToSuper.new
 		if node.iter
			model.block_arg = node_to_model(node.iter)
		end
 		model 		
 	when 'SUPERNODE'
 		model = RubyMM::SuperCall.new
 	
 		if node.args.node_type.name == 'BLOCKPASSNODE'
			model.block_arg = node_to_model(node.args)
			args_to_process = node.args.args
		else
			args_to_process = node.args
		end

		if node.iter==nil and args_to_process.is_a?IterNode			
			model.block_arg = node_to_model(args_to_process)
			# no args
		else
			model.block_arg = node_to_model(node.iter) if node.iter
			model.args = my_args_flattener(args_to_process) if args_to_process
		end

 		model 		
	when 'CALLNODE'
		model = RubyMM::Call.new
		model.name = node.name
		model.receiver = node_to_model node.receiver
		
		if node.args.node_type.name == 'BLOCKPASSNODE'
			model.block_arg = node_to_model(node.args)
			args_to_process = node.args.args
		else
			args_to_process = node.args
		end

		if node.iter==nil and args_to_process.is_a?IterNode			
			model.block_arg = node_to_model(args_to_process)
			# no args
		else
			model.block_arg = node_to_model(node.iter) if node.iter
			model.args = my_args_flattener(args_to_process) if args_to_process
		end

		model.implicit_receiver = false
		model
	when 'VCALLNODE'
		model = RubyMM::Call.new
		model.name = node.name
		#model.receiver = node_to_model node.receiver
		#model.args = args_to_model node.args
		model.implicit_receiver = false
		model
	when 'FCALLNODE'
		model = RubyMM::Call.new
		model.name = node.name

		if node.args.node_type.name == 'BLOCKPASSNODE'
			model.block_arg = node_to_model(node.args)
			args_to_process = node.args.args
		else
			args_to_process = node.args
		end

		if node.iter==nil and args_to_process.is_a?IterNode			
			model.block_arg = node_to_model(args_to_process)
			# no args
		else
			model.block_arg = node_to_model(node.iter) if node.iter
			model.args = my_args_flattener(args_to_process) if args_to_process
		end

		model.implicit_receiver = true
		model		
	when 'DEFNNODE'
		model = RubyMM::Def.new
		model.name = node.name
		#puts "NODE BODY: #{node.body}"	
		if node.body==nil
			model.body = nil
		elsif node.body.node_type.name=='RESCUENODE'
			rescue_node = node.body
			model.body = node_to_model(rescue_node.body)
	 		rescue_body_node = rescue_node.rescue
	 		raise 'AssertionFailed' unless rescue_body_node.node_type.name=='RESCUEBODYNODE'
	 		rescue_clause_model = RubyMM::RescueClause.new
	 		rescue_clause_model.body = node_to_model(rescue_body_node.body)
	 		model.rescue_clauses = model.rescue_clauses << rescue_clause_model
		else
			model.body = node_to_model(node.body,model)
		end
		model.onself = false
		model
	when 'DEFSNODE'
		model = RubyMM::Def.new
		model.name = node.name
		model.body = node_to_model node.body
		model.onself = true
		model
	when 'BLOCKNODE'
		model = RubyMM::Block.new		
		for i in 0..(node.size-1)
			content_at_i = node_to_model(node.get i)
			#puts "Adding to contents #{content_at_i}" 
			model.contents = (model.contents << content_at_i)
			#puts "Contents #{model.contents.class}"
		end
		model
	when 'EVSTRNODE'
		node_to_model(node.body)
	when 'CLASSNODE'
		model = RubyMM::ClassDecl.new
		model.defname = node_to_model(node.getCPath)
		model.super_class = node_to_model(node.super)
		body_node_to_contents(node.body_node,model)
		model
	when 'SCLASSNODE'
		model = RubyMM::SingletonClassDecl.new
		model.object = node_to_model(node.receiver)
		body_node_to_contents(node.body_node,model)
		model		
	when 'MODULENODE'
		model = RubyMM::ModuleDecl.new
		model.defname = node_to_model(node.getCPath)
		body_node_to_contents(node.body_node,model)
		model
	when 'COLON2NODE'
		model = RubyMM::Constant.new
		model.name = node.name
		model.container = node_to_model(node.left_node)
 		model
 	when 'SYMBOLNODE'
 		model = RubyMM::Symbol.new
 		model.name = node.name
 		model
 	when 'CONSTNODE'
 		model = RubyMM::Constant.new
 		model.name = node.name
 		model
 	when 'IFNODE'
 		model = RubyMM::IfStatement.new
 		model.condition = node_to_model(node.condition)
 		model.then_body = node_to_model(node.then_body)  		
 		model.else_body = node_to_model(node.else_body)
 		model 		
 	when 'HASHNODE'
 		model = RubyMM::HashLiteral.new
 		count = node.get_list_node.count / 2
 		for i in 0..(count-1)
 			k_node = node.get_list_node[i*2]
 			k = node_to_model(k_node)
 			v_node = node.get_list_node[i*2 +1]
 			v = node_to_model(v_node)
 			pair = RubyMM::HashPair.build key: k, value: v
 			model.pairs = model.pairs << pair
 		end
 		model
 	when 'DEFINEDNODE'
 		model = RubyMM::IsDefined.new
 		model.value = node_to_model(node.expression)
 		model
 	when 'ARRAYNODE'
 		model = RubyMM::ArrayLiteral.new
 		for i in 0..(node.count-1)
 			v_node = node[i]
 			v = node_to_model(v_node)
 			model.values = model.values << v
 		end
 		model
 	when 'SPLATNODE'
 		model = RubyMM::Splat.new
 		model.splatted = node_to_model(node.value)
 		model
 	when 'UNARYCALLNODE'
 		model = RubyMM::UnaryOperation.new
 		model.value = node_to_model(node.receiver)
 		model.operator_name = node.lexical_name
 		model
 	when 'ZARRAYNODE'
 		RubyMM::ArrayLiteral.new
 	when 'RETRYNODE'
 		RubyMM::RetryStatement.new
 	when 'BEGINNODE'
 		model = RubyMM::BeginEndBlock.new
 		if node.body==nil
 			# nothing to do, model.body should be nil
 		elsif node.body.node_type.name =='RESCUENODE'
	 		rescue_node = node.body
	 		assert_node_type(rescue_node,'RESCUENODE')
	 		model.body = node_to_model(rescue_node.body)
	 		rescue_body_node = rescue_node.rescue
	 		assert_node_type(rescue_body_node,'RESCUEBODYNODE')
	 		rescue_clause_model = RubyMM::RescueClause.new
		 	rescue_clause_model.body = node_to_model(rescue_body_node.body)
		 	model.rescue_clauses = model.rescue_clauses << rescue_clause_model
		else
			model.body = node_to_model(node.body)
		end
 		model
 	when 'RETURNNODE'
 		model = RubyMM::Return.new
 		model.value = node_to_model(node.value)
 		model
 	when 'ANDNODE'
 		model = RubyMM::AndOperator.new
 		model.left = node_to_model(node.first)
 		model.right = node_to_model(node.second)
 		model
 	when 'ORNODE'
 		model = RubyMM::OrOperator.new
 		model.left = node_to_model(node.first)
 		model.right = node_to_model(node.second)
 		model
 	when 'ITERNODE'
 		model = RubyMM::CodeBlock.new
 		model.args = args_to_model(node.var)
 		model.body = node_to_model(node.body)
 		model
 	when 'ARGUMENTNODE'
 		model = RubyMM::Argument.new
 		model.name = node.name
 		model
 	when 'RESTARG'
 		model = RubyMM::Argument.new
 		model.name = node.name
 		model 		
 	when 'BLOCKPASSNODE'
 		model = RubyMM::BlockReference.new
 		#raise ParsingError.new(node,"Unexpected something that is not a symbol but a #{node.body}") unless node.body.is_a? SymbolNode
 		model.value = node_to_model(node.body)
 		model
 	when 'ARGSCATNODE'
 		model = RubyMM::ArrayLiteral.new
 		model.values = my_args_flattener(node)
 		model
 	when 'ARGSPUSHNODE'
 		model = RubyMM::ArrayLiteral.new
 		model.values = my_args_flattener(node)
 		model 		
	else		
		#n = node
		#while n
		#	puts "> #{n}"
		#	n = n.parent
		#end
		unknown_node_type_found(node)
		#raise "I don't know how to deal with #{node.node_type.name} (position: #{node.position})"
	end
end

def self.unknown_node_type_found(node)
	if RubyMM.skip_unknown_node
		puts "skipping #{node.node_type.name} at #{node.position}..."
	else
		raise UnknownNodeType.new(node)
	end
end

def self.populate_from_list(array,list_node)
	if list_node.respond_to? :size
		for i in 0..(list_node.size-1) 
			array << node_to_model(list_node.get i)
		end
	else
		array << node_to_model(list_node)
	end
end

def self.args_to_model(args_node)
	args=[]
	if args_node.is_a? ArrayNode
		#puts "ARGS #{args_node} #{args_node.size} #{args_node.class}"
		for i in 0..(args_node.size-1) 
			#puts "DEALING WITH #{i} #{args_node.get i} #{(args_node.get i).class}"
			args << node_to_model(args_node.get i)
		end
		args
	elsif args_node.is_a? ListNode 
		for i in 0..(args_node.size-1) 
			#puts "DEALING WITH #{i} #{args_node.get i} #{(args_node.get i).class}"
			args << node_to_model(args_node.get i)
		end
		args 		
	elsif args_node.is_a? ArgsNode
		populate_from_list(args,args_node.pre) if args_node.pre
		populate_from_list(args,args_node.optional) if args_node.optional
		populate_from_list(args,args_node.rest) if args_node.rest
		populate_from_list(args,args_node.post) if args_node.post
		args
	elsif args_node.is_a? Node
		args << node_to_model(args_node)
		args
	else
		raise UnknownNodeType.new(args_node,'in args')
	end
end

end