require 'jruby-parser'
require 'metamodel'
require 'java'
require 'emf_jruby'

dir = File.dirname(__FILE__)
Dir[dir+'/jars/*.jar'].each do |jar|
	puts "loading #{jar}"
	require jar
end

java_import org.jrubyparser.ast.ArrayNode
#java_import org.eclipse.core.runtime.IPath
#java_import org.eclipse.emf.ecore.resource.URIConverter.WriteableOutputStream

def to_xmi(code)
	tree = parse(code)

	writer = nil
	encoding = nil
	org.eclipse.emf.ecore.resource.URIConverter.WriteableOutputStream.new(writer,encoding)
	#inmemory_uri = URIConverter.WriteableOutputStream.new(writer,encoding)
end

def parse(code)
	tree = JRubyParser.parse(code)
	tree_to_model(tree)
end

def tree_to_model(tree)
	unless tree.node_type.name=='ROOTNODE' 
		raise 'Root expected'
	end
	node_to_model tree.body
end

def node_to_model(node)
	case node.node_type.name
	when 'NEWLINENODE'
		node_to_model node.next_node
	when 'CALLNODE'
		model = RubyMM::Call.new
		model.name = node.name
		model.receiver = node_to_model node.receiver
		model.args = args_to_model node.args
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
	else		
		raise "I don't know how to deal with #{node.node_type.name}"
	end
end

def args_to_model(args_node)
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