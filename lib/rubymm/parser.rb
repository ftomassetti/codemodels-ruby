require 'jruby-parser'
require 'rubymm/metamodel'
require 'java'
require 'emf_jruby'

java_import org.jrubyparser.ast.ArrayNode
java_import org.jrubyparser.ast.ListNode

module RubyMM

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

def self.node_to_model(node)
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
		#puts "Body #{node_to_model node.body}"
		model.body = node_to_model node.body
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
		body = node_to_model(node.body_node)
		if body
			if body.is_a? RubyMM::Block	
				body.contents.each do |el|
					model.contents = model.contents << el 
				end
			else
				model.contents = model.contents << body
			end
		end
		model
	when 'NILNODE'
		if node.is_a? Java::OrgJrubyparserAst::NilImplicitNode
			return nil
		else
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
 		#puts node.methods.sort
 		#puts "LASGN #{node.name.class} #{node.value.class}"
 		model.name_assigned = node.name
 		model.value = node_to_model(node.value)
 		model
 	when 'LOCALVARNODE'
 		model = RubyMM::LocalVarAccess.new
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
 	when 'CONSTDECLNODE'
 		raise 'Const decl node: not implemented'
	else		
		raise "I don't know how to deal with #{node.node_type.name}"
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
	else 
		raise "I don't know how to deal with #{args_node.class}"
	end
end

end