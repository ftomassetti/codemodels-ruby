require 'jruby-parser'
require 'rubymm/metamodel'
require 'emf_jruby'

java_import org.jrubyparser.ast.ArrayNode
java_import org.jrubyparser.ast.ListNode
java_import org.jrubyparser.ast.BlockPassNode
java_import org.jrubyparser.ast.ArgsNode

module RubyMM

def self.parse_file(path)
	content = IO.read(path)
	self.parse(content)
end

def self.parse(code)
	tree = JRubyParser.parse(code)
	#puts "Code: #{code} Root: #{tree}"
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

def self.get_var_name_depending_on_parser_version(node)
	if node.respond_to? :lexical_name # depends on the version...
		return node.name
 	else
 		return node.name[1..-1]
 	end
 end

def self.node_to_model(node,parent_model=nil)
	return nil if node==nil
	#puts "#{node} #{node.node_type.name}"
	case node.node_type.name
	when 'NEWLINENODE'
		node_to_model node.next_node
	when 'CALLNODE'
		model = RubyMM::Call.new
		model.name = node.name
		model.receiver = node_to_model node.receiver
		model.args = args_to_model node.args
		if node.iter
			model.block_arg = node_to_model(node.iter)
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
		#model.receiver = node_to_model node.receiver
		model.args = args_to_model node.args
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
	when 'EVSTRNODE'
		node_to_model(node.body)
	when 'CLASSNODE'
		model = RubyMM::ClassDecl.new
		model.defname = node_to_model(node.getCPath)
		model.super_class = node_to_model(node.super)
		body_node_to_contents(node.body_node,model)
		model
	when 'MODULENODE'
		model = RubyMM::ModuleDecl.new
		model.defname = node_to_model(node.getCPath)
		body_node_to_contents(node.body_node,model)
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
 	when 'LOCALASGNNODE'
 		model = RubyMM::LocalVarAssignment.new
 		model.name_assigned = node.name
 		model.value = node_to_model(node.value)
 		model
 	when 'LOCALVARNODE'
 		model = RubyMM::LocalVarAccess.new
 		model.name = node.name
 		model
 	when 'DVARNODE'
 		model = RubyMM::BlockVarAccess.new
 		model.name = node.name
 		model
 	when 'FALSENODE'
 		model = RubyMM::BooleanLiteral.new
 		model.value = false
 		model
 	when 'TRUENODE'
 		model = RubyMM::BooleanLiteral.new
 		model.value = true
 		model
 	when 'IFNODE'
 		model = RubyMM::IfStatement.new
 		model
 	when 'GLOBALVARNODE'
 		model = RubyMM::GlobalVarAccess.new
 		model.name = get_var_name_depending_on_parser_version(node)
 		model
 	when 'GLOBALASGNNODE'
 		model = RubyMM::GlobalVarAssignment.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node)
 		model.value = node_to_model(node.value)
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
 	when 'ARRAYNODE'
 		model = RubyMM::ArrayLiteral.new
 		for i in 0..(node.count-1)
 			v_node = node[i]
 			v = node_to_model(v_node)
 			model.values = model.values << v
 		end
 		model
 	when 'ZARRAYNODE'
 		RubyMM::ArrayLiteral.new
 	when 'BEGINNODE'
 		model = RubyMM::BeginRescue.new
 		rescue_node = node.body
 		raise 'AssertionFailed' unless rescue_node.node_type.name=='RESCUENODE'
 		model.body = node_to_model(rescue_node.body)
 		rescue_body_node = rescue_node.rescue
 		raise 'AssertionFailed' unless rescue_body_node.node_type.name=='RESCUEBODYNODE'
 		rescue_clause_model = RubyMM::RescueClause.new
	 	rescue_clause_model.body = node_to_model(rescue_body_node.body)
	 	model.rescue_clauses = model.rescue_clauses << rescue_clause_model
 		model
 	when 'ATTRASSIGNNODE'
 		model = RubyMM::ElementAssignement.new
 		model.array = node_to_model(node.receiver)
 		model.element = node_to_model(node.args[0])
 		model.value = node_to_model(node.args[1])
 		model
 	when 'INSTASGNNODE'
 		model = RubyMM::InstanceVarAssignement.new
 		model.name_assigned = get_var_name_depending_on_parser_version(node)
 		model.value = node_to_model(node.value)
 		model
 	when 'INSTVARNODE'
 		RubyMM::InstanceVarAccess.build get_var_name_depending_on_parser_version(node)
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
 	when 'OPASGNORNODE'
 		model = RubyMM::OrAssignment.new
 		# assigned : from access to variable
 		# value    : from assignement to value 		
 		model.assigned = node_to_model(node.first)
 		model.value = node_to_model(node.second).value
 		model
 	when 'ITERNODE'
 		model = RubyMM::CodeBlock.new
 		model.args = args_to_model(node.var)
 		model.body = node_to_model(node.body)
 		model
 	when 'CONSTDECLNODE'
 		raise 'Const decl node: not implemented'
 	when 'ARGUMENTNODE'
 		model = RubyMM::Argument.new
 		model.name = node.name
 		model
	else		
		#n = node
		#while n
		#	puts "> #{n}"
		#	n = n.parent
		#end
		raise "I don't know how to deal with #{node.node_type.name}"
	end
end

def self.populate_from_list(array,list_node)
	for i in 0..(list_node.size-1) 
		array << node_to_model(list_node.get i)
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
		populate_from_list(args,args_node.pre)
		populate_from_list(args,args_node.optional) if args_node.optional
		populate_from_list(args,args_node.rest) if args_node.rest
		populate_from_list(args,args_node.post) if args_node.post
		args
	#elsif args_node.is_a? BlockPassNode
	#	raise 'BLOCKPASSNODE: what should I do with that?'
	else 
		raise "I don't know how to deal with #{args_node.class}"
	end
end

end