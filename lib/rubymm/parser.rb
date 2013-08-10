require 'jruby-parser'
require 'rubymm/metamodel'
require 'java'
require 'emf_jruby'

java_import org.jrubyparser.ast.ArrayNode

module RubyMM

def self.parse(code)
	tree = JRubyParser.parse(code)
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
		model
	when 'CLASSNODE'
		model = RubyMM::ClassDecl.new
		model.defname = node_to_model(node.getCPath)
		model.super_class = node_to_model(node.super)
		body = node_to_model(node.body_node)
		# if it is a single element...
		if not body
			# nothing to do
			#puts "\tbody null, ignored"
		elsif not body.is_a? Enumerable
			#puts "\tAdding #{body}"
			#non stampa body e poi non fa la cosa sotto
			model.body = model.body << body
			#puts "\tmodel.body #{model.body} (count: #{model.body.count})"
		else
			raise 'not implemented'
		end
		#model.body = body
		model
	when 'NILNODE'
		nil
	when 'COLON2NODE'
		model = RubyMM::Constant.new
		model.name = node.name
		model.container = node_to_model(node.left_node)
		#puts "COLON2NODE #{node}"
		#puts "\tname:#{node.name}"
		#puts "\tname:#{node.value}"
		#model.container =
 		model
 	when 'SYMBOLNODE'
 		model = RubyMM::Symbol.new
 		model
 	when 'CONSTNODE'
 		model = RubyMM::Constant.new
 		model.name = node.name
 		model
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
	else 
		raise "I don't know how to deal with #{args_node.class}"
	end
end

end