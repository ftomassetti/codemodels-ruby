require 'jruby-parser'
require 'emf_jruby'
require 'codemodels'
require 'codemodels/ruby/metamodel'

java_import org.jrubyparser.ast.Node
java_import org.jrubyparser.ast.ArrayNode
java_import org.jrubyparser.ast.ListNode
java_import org.jrubyparser.ast.BlockPassNode
java_import org.jrubyparser.ast.ArgsNode
java_import org.jrubyparser.ast.IterNode
java_import org.jrubyparser.ast.SymbolNode
java_import org.jrubyparser.ast.ArrayNode

java_import org.jrubyparser.util.StaticAnalyzerHelper

module CodeModels

module Ruby

module RawNodeAccessModule
	attr_accessor :original_node
end

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

def self.containment_pos(node)
	container = node.eContainer
	children  = node.eContainer.send(node.eContainingFeature)
	if children.respond_to?(:each)
		children.each_with_index do |c,i|
			return i if c==node
		end
		raise "Not found"
	else
		raise "Not found" unless children==node
		0
	end
end

# node tree contains the original 
# TO BE FIXED
def self.corresponding_node(model_element,node_tree)
	return node_tree unless model_element.eContainer
	corresponding_parent_node = corresponding_node(model_element.eContainer,node_tree)
	containment_pos = containment_pos(model_element)
	containing_feat = model_element.eContainingFeature

	children = corresponding_parent_node.send(containing_feat)
	if children.respond_to?(:each)
		children[containment_pos]
	else
		children
	end
end

def self.assert_node_type(node,type)
	raise ParsingError.new(node,"AssertionFailed: #{type} expected but #{node.node_type.name} found") unless node.node_type.name==type
end


def self.parse_code(code)
	tree = JRubyParser.parse(code, {:version=>JRubyParser::Compat::RUBY2_0})
	tree_to_model(tree)
end

# DEPRECATED
def self.parse(code)
	parse_code(code)
end

def self.node_tree_from_code(code)
	JRubyParser.parse(code, {:version=>JRubyParser::Compat::RUBY2_0})
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
		if body.is_a? Ruby::Block	
			body.contents.each do |el|
				container_node.addContents(el)
			end
		else
			container_node.addContents( body )
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
			res << Ruby.splat(node_to_model(args_node.secondNode))
		end
		res.class.class_eval do
			include RawNodeAccessModule
		end
		res.original_node = args_node.secondNode
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

def self.process_body(node,model)
	if node.body==nil
		model.body = nil
	elsif node.body.node_type.name=='RESCUENODE'
		rescue_node = node.body
		model.body = node_to_model(rescue_node.body)
 		rescue_body_node = rescue_node.rescue
 		raise 'AssertionFailed' unless rescue_body_node.node_type.name=='RESCUEBODYNODE'
 		rescue_clause_model = Ruby::RescueClause.new

		rescue_clause_model.class.class_eval do
			include RawNodeAccessModule
		end
		rescue_clause_model.original_node = node

 		rescue_clause_model.body = node_to_model(rescue_body_node.body)
 		model.addRescue_clauses( rescue_clause_model )
 	elsif node.body.node_type.name=='ENSURENODE'
 		ensure_node = node.body
 		model.ensure_body = node_to_model(ensure_node.ensure)
 		model.body = node_to_model(ensure_node.body)	 		
	else
		model.body = node_to_model(node.body,model)
	end
end

def self.process_formal_args(node,model)
	#puts "\nArgs are: #{node.args}"

	args = []
	args_node = node.args
	populate_from_list(args,args_node.pre) if args_node.pre
	populate_from_list(args,args_node.optional) if args_node.optional
	populate_from_list(args,args_node.rest) if args_node.rest
	populate_from_list(args,args_node.post) if args_node.post
	#puts "\tCollected args: #{args}"

	args.each do |a| 
		if a.is_a?(Argument)
			fa = FormalArgument.new
			fa.name = a.name
			fa.class.class_eval do
				include RawNodeAccessModule
			end
			fa.original_node = node
			model.addFormal_args(fa)
		elsif a.is_a?(FormalArgument)
			if a.default_value.is_a? VarAssignment
				a.default_value = a.default_value.value
			end
			model.addFormal_args(a)
		else
			raise "Unexpected #{a.class}"
		end
	end
	#puts "\tFormal args: #{model.formal_args}"
	#model.formal_args = args_to_model(my_args_flattener(node.args))
end

def self.node_to_model(node,parent_model=nil)
	return nil if node==nil
	#puts "#{node} #{node.node_type.name}"
	case node.node_type.name
	when 'NEWLINENODE'
		model = node_to_model node.next_node

	##
	## Literals
	##
	when 'FLOATNODE'
		model = Ruby::FloatLiteral.new
		model.value = node.value
		model
	when 'FIXNUMNODE'
		model = Ruby::IntLiteral.new
		model.value = node.value
		model
	when 'STRNODE'
		model = Ruby::StaticStringLiteral.new
		model.value = node.value
		model
	when 'DSTRNODE'
		model = Ruby::DynamicStringLiteral.new
		#model.value = node.value
		for i in 0..(node.size-1)
			model.addPieces( node_to_model(node.get i) )
		end
		model
	when 'DXSTRNODE'
		model = Ruby::CmdLineStringLiteral.new
		for i in 0...node.size
			model.addPieces( node_to_model(node.get i) )
		end
		model	
	when 'DSYMBOLNODE'
		model = Ruby::DynamicSymbol.new
		for i in 0...node.size
			model.addPieces( node_to_model(node.get i) )
		end
		model
	when 'DREGEXPNODE'
		model = Ruby::DynamicRegExpLiteral.new
		for i in 0...node.size
			model.addPieces( node_to_model(node.get i) )
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
			model = Ruby::NilLiteral.new
		end
 	when 'FALSENODE'
 		model = Ruby::BooleanLiteral.new
 		model.value = false
 		model
 	when 'TRUENODE'
 		model = Ruby::BooleanLiteral.new
 		model.value = true
 		model
 	when 'REGEXPNODE'
 		model = Ruby::StaticRegExpLiteral.new
 		model.value = node.value
 		model

 	###
 	### Variable accesses
 	###
 	when 'LOCALVARNODE'
 		model = Ruby::LocalVarAccess.new
 		model.name = node.name
 		model
 	when 'DVARNODE'
 		model = Ruby::BlockVarAccess.new
 		model.name = node.name
 		model
 	when 'GLOBALVARNODE'
 		model = Ruby::GlobalVarAccess.new
 		model.name = get_var_name_depending_on_parser_version(node)
 		model
 	when 'CLASSVARNODE'
 		model = Ruby::ClassVarAccess.new
 		model.name = get_var_name_depending_on_parser_version(node,2)
 		model
 	when 'INSTVARNODE'
 		model = Ruby::InstanceVarAccess.build get_var_name_depending_on_parser_version(node) 	

 	###
 	### Variable Assignments
 	###
  	when 'LOCALASGNNODE'
 		model = Ruby::LocalVarAssignment.new
 		model.name_assigned = node.name
 		model.value = node_to_model(node.value)
 		model		
  	when 'DASGNNODE'
 		model = Ruby::BlockVarAssignment.new
 		model.name_assigned = node.name
 		model.value = node_to_model(node.value)
 		model	 		
 	when 'GLOBALASGNNODE'
 		model = Ruby::GlobalVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node)
 		model.value = node_to_model(node.value)
 		model 		
 	when 'CLASSVARASGNNODE'
 		model = Ruby::ClassVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node,2)
 		model.value = node_to_model(node.value)
 		model 		
 	when 'INSTASGNNODE'
 		model = Ruby::InstanceVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node)
 		model.value = node_to_model(node.value)
 		model

 	###
 	### Other assignments
 	###

 	when 'OPELEMENTASGNNODE'
 		model = Ruby::ElementOperationAssignment.new
 		model.container = node_to_model(node.receiver)
 		model.element = node_to_model(node.args[0])
 		model.value = node_to_model(node.value)
 		model.operator = node.operator_name
 		model
 	when 'ATTRASSIGNNODE'
 		model = Ruby::ElementAssignment.new
 		model.container = node_to_model(node.receiver)
 		if node.args # apparently it can be null...
 			model.element = node_to_model(node.args[0])
 			model.value = node_to_model(node.args[1])
 		end
 		model
 	when 'OPASGNORNODE'
 		model = Ruby::OrAssignment.new
 		# assigned : from access to variable
 		# value    : from Assignment to value 		
 		model.assigned = node_to_model(node.first)
 		model.value = node_to_model(node.second).value
 		model
 	when 'MULTIPLEASGNNODE'
 		# TODO consider asterisk
 		model = Ruby::MultipleAssignment.new
 		if node.pre
 			for i in 0..(node.pre.count-1)
 				model.addAssignments( node_to_model(node.pre.get(i)) )
 			end
 		end
 		values_model = node_to_model(node.value)
 		if values_model.respond_to? :values
 			values_model.values.each {|x| model.addValues(x) }
 		else
 			model.addValues( values_model )
 		end
 		# TODO consider rest and post!
 		model
 	when 'MULTIPLEASGN19NODE'
  		# TODO consider asterisk
 		model = Ruby::MultipleAssignment.new
 		if node.pre
 			for i in 0..(node.pre.count-1)
 				model.addAssignments( node_to_model(node.pre.get(i)) )
 			end
 		end
 		values_model = node_to_model(node.value)
 		if values_model.respond_to? :values
 			values_model.values.each {|x| model.addValues(x)}
 		else
 			model.addValues( values_model )
 		end
 		# TODO consider rest and post!
 		model
 	when 'OPASGNNODE'
 		model = Ruby::OperatorAssignment.new
 		model.value = node_to_model(node.valueNode)
 		model.container = node_to_model(node.receiverNode)
 		model.element_name = node.variable_name
 		model.operator_name = node.operator_name
    	model

 	###
 	### Constants
 	###

 	when 'CONSTDECLNODE'
 		model = Ruby::ConstantDecl.new
 		model.name = node.name
 		model.value = node_to_model(node.value)
 		model

 	###
 	### Statements
 	###

 	when 'ALIASNODE'
 		model = Ruby::AliasStatement.new
 		model.old_name = node_to_model(node.oldName)
 		model.new_name = node_to_model(node.newName)
 		model
 	when 'CASENODE'
 		model = Ruby::CaseStatement.new
 		for ci in 0..(node.cases.count-1)
 			c = node.cases[ci]
 			model.addWhen_clauses( node_to_model(c) )
 		end
 		model.else_body = node_to_model(node.else)
 		model
 	when 'WHENNODE'
 		model = Ruby::WhenClause.new
 		model.body = node_to_model(node.body)
 		model.condition = node_to_model(node.expression)
 		model
 	when 'UNDEFNODE'
 		model = Ruby::UndefStatement.new
 		model.name = node_to_model(node.name)
 		model
 	when 'WHILENODE'
 		model = Ruby::WhileStatement.new
 		model.body = node_to_model(node.body)
 		model.condition = node_to_model(node.condition)
 		model
 	when 'FORNODE'
 		model = Ruby::ForStatement.new
 		model.body = node_to_model(node.body)
 		model.collection = node_to_model(node.iter)
 		model.iterator = node_to_model(node.var)
 		model 		
 	when 'BREAKNODE'
 		model = Ruby::BreakStatement.new
 	when 'UNTILNODE'
 		model = Ruby::UntilStatement.new
 		model.body = node_to_model(node.body)
 		model.condition = node_to_model(node.condition)
 		model 		
 	when 'RESCUENODE'
 		model = Ruby::RescueStatement.new
 		model.body = node_to_model(node.body)
 		model.value = node_to_model(node.rescueNode.body)
 		model

 	###
 	### The rest
 	###

 	when 'NTHREFNODE'
 		model = Ruby::NthGroupReference.build(node.matchNumber)
 	when 'YIELDNODE'
 		model = Ruby::YieldStatement.new
	when 'NEXTNODE'
 		model = Ruby::NextStatement.new 		
 	when 'COLON3NODE'
 		model = Ruby::GlobalScopeReference.new
 		model.name = node.name
 		model
 	when 'DOTNODE'
 		model = Ruby::Range.new
 		model.lower = node_to_model(node.beginNode)
 		model.upper = node_to_model(node.endNode)
 		model
 	when 'MATCH2NODE'
 		model = Ruby::RegexTryer.new
 		model.checked_value = node_to_model(node.value)
 		model.regex = node_to_model(node.receiver)
 		model 		
 	when 'MATCH3NODE'
 		model = Ruby::RegexMatcher.new
 		model.checked_value = node_to_model(node.value)
 		model.regex = node_to_model(node.receiver)
 		model
 	when 'LITERALNODE'
 		model = Ruby::LiteralReference.new
 		model.value = node.name
 		model
 	when 'SELFNODE'
 		model = Ruby::Self.new
 		model
 	when 'ZSUPERNODE'
 		model = Ruby::CallToSuper.new
 		if node.iter
			model.block_arg = node_to_model(node.iter)
		end
 		model 		
 	when 'SUPERNODE'
 		model = Ruby::SuperCall.new
 	
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
		model = Ruby::ExplicitReceiverCall.new
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

		model
	when 'VCALLNODE'
		model = Ruby::ExplicitReceiverCall.new
		model.name = node.name
		model
	when 'FCALLNODE'
		model = Ruby::ImplicitReceiverCall.new
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

		model		
	when 'DEFNNODE'
		model = Ruby::InstanceDef.new
		model.name = node.name
		process_formal_args(node,model)
		process_body(node,model)
		model
	when 'DEFSNODE'
		model = Ruby::SelfDef.new
		model.name = node.name
		process_formal_args(node,model)
		process_body(node,model)
		model
	when 'BLOCKNODE'
		model = Ruby::Block.new		
		for i in 0..(node.size-1)
			content_at_i = node_to_model(node.get i)
			#puts "Adding to contents #{content_at_i}" 
			model.addContents( content_at_i )
			#puts "Contents #{model.contents.class}"
		end
		model
	when 'BACKREFNODE'
		model = Ruby::BackReference.new
	when 'EVSTRNODE'
		model = node_to_model(node.body)
	when 'CLASSNODE'
		model = Ruby::ClassDecl.new
		model.defname = node_to_model(node.getCPath)
		model.super_class = node_to_model(node.super)
		body_node_to_contents(node.body_node,model)
		model
	when 'SCLASSNODE'
		model = Ruby::SingletonClassDecl.new
		model.object = node_to_model(node.receiver)
		body_node_to_contents(node.body_node,model)
		model		
	when 'MODULENODE'
		model = Ruby::ModuleDecl.new
		model.defname = node_to_model(node.getCPath)
		body_node_to_contents(node.body_node,model)
		model
	when 'COLON2NODE'
		model = Ruby::Constant.new
		model.name = node.name
		model.container = node_to_model(node.left_node)
 		model
 	when 'SYMBOLNODE'
 		model = Ruby::Symbol.new
 		model.name = node.name
 		model
 	when 'CONSTNODE'
 		model = Ruby::Constant.new
 		model.name = node.name
 		model
 	when 'IFNODE'
 		model = Ruby::IfStatement.new
 		model.condition = node_to_model(node.condition)
 		model.then_body = node_to_model(node.then_body)  		
 		model.else_body = node_to_model(node.else_body)
 		model 		
 	when 'HASHNODE'
 		model = Ruby::HashLiteral.new
 		count = node.get_list_node.count / 2
 		for i in 0..(count-1)
 			k_node = node.get_list_node[i*2]
 			k = node_to_model(k_node)
 			v_node = node.get_list_node[i*2 +1]
 			v = node_to_model(v_node)
 			pair = Ruby::HashPair.build key: k, value: v
 			model.addPairs(pair)
 		end
 		model
 	when 'DEFINEDNODE'
 		model = Ruby::IsDefined.new
 		model.value = node_to_model(node.expression)
 		model
 	when 'ARRAYNODE'
 		model = Ruby::ArrayLiteral.new
 		for i in 0..(node.count-1)
 			v_node = node[i]
 			v = node_to_model(v_node)
 			model.addValues(v)
 		end
 		model
 	when 'SPLATNODE'
 		model = Ruby::Splat.new
 		model.splatted = node_to_model(node.value)
 		model
 	when 'UNARYCALLNODE'
 		model = Ruby::UnaryOperation.new
 		model.value = node_to_model(node.receiver)
 		model.operator_name = node.lexical_name
 		model
 	when 'ZARRAYNODE'
 		model = Ruby::ArrayLiteral.new
 	when 'RETRYNODE'
 		model = Ruby::RetryStatement.new
 	when 'BEGINNODE'
 		model = Ruby::BeginEndBlock.new
 		process_body(node,model)
 		model
 	when 'RETURNNODE'
 		model = Ruby::Return.new
 		model.value = node_to_model(node.value)
 		model
 	when 'ANDNODE'
 		model = Ruby::AndOperator.new
 		model.left = node_to_model(node.first)
 		model.right = node_to_model(node.second)
 		model
 	when 'ORNODE'
 		model = Ruby::OrOperator.new
 		model.left = node_to_model(node.first)
 		model.right = node_to_model(node.second)
 		model
 	when 'ITERNODE'
 		model = Ruby::CodeBlock.new
 		model.args = clean_args(args_to_model(node.var))
 		model.body = node_to_model(node.body)
 		model
 	when 'ARGUMENTNODE'
 		model = Ruby::Argument.new
 		model.name = node.name
 		model
 	when 'RESTARG'
 		model = Ruby::Argument.new
 		model.name = node.name
 		model 		
 	when 'BLOCKPASSNODE'
 		model = Ruby::BlockReference.new
 		#raise ParsingError.new(node,"Unexpected something that is not a symbol but a #{node.body}") unless node.body.is_a? SymbolNode
 		model.value = node_to_model(node.body)
 		model
 	when 'ARGSCATNODE'
 		model = Ruby::ArrayLiteral.new
 		model.values = my_args_flattener(node)
 		model
 	when 'ARGSPUSHNODE'
 		model = Ruby::ArrayLiteral.new
 		model.values = my_args_flattener(node)
 		model 		
 	when 'OPTARGNODE'
 		model = Ruby::FormalArgument.new
 		model.name = node.name
 		model.default_value = node_to_model(node.value)
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
	model.class.class_eval do
		include RawNodeAccessModule
	end
	#puts "Setting variable for #{model} to #{node}" if model.is_a?(InstanceDef)
	#model.instance_variable_set(:@original_node,node)
	model.original_node = node
	model
end

def self.unknown_node_type_found(node)
	if Ruby.skip_unknown_node
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

def self.clean_args(args)
	for i in 0..(args.count-1) 
		if args[i].is_a? Ruby::MultipleAssignment
			old = args[i]
			args[i] = Ruby::SplittedArgument.new
			old.assignments.each {|a| args[i].names = args[i].names << a.name_assigned}
		end
	end
	args
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

class Parser < CodeModels::Parser

	def parse_code(code)
		CodeModels::Ruby.parse_code(code)
	end

end

end
end