require 'simplecov'
SimpleCov.start do
	add_filter "/test/"	
end

require 'test/unit'
require 'ruby-lightmodels'

module TestHelper

	include LightModels

	def assert_is_int(node,value)
		assert node.is_a? Ruby::IntLiteral
		assert_equal value, node.value
	end

	def assert_is_str(node,value)
		assert node.is_a? Ruby::StringLiteral
		assert_equal value, node.value
	end

	# DEPRECATED
	def assert_right_class(node,clazz)
		assert_class(clazz,node)
	end

	def assert_class(clazz,node)
		assert node.is_a?(clazz), "Instead #{node.class}"
	end

	def assert_simple_const(node,name)
		assert_right_class node,Ruby::Constant
		assert_equal name, node.name
		assert_equal nil, node.container
	end

	def assert_node(node,clazz,values={})
		assert_right_class node,clazz
		assert_values node,values
	end

	def assert_values(node,values)
		values.each do |name,expected_value|
			getter = name
			actual_value = node.send getter
			assert_equal expected_value,actual_value
		end
	end

	def relative_path(path)
		File.join(File.dirname(__FILE__),path)
	end

	def read_test_data(filename)
		dir = File.dirname(__FILE__)
		dir = File.join(dir,'data')
		path = File.join(dir,filename)
		IO.read(path)
	end

	def assert_map_equal(exp,act,model=nil)
		fail "Unexpected keys #{act.keys-exp.keys}. Actual map: #{act}" if (act.keys-exp.keys).count > 0
		fail "Missing keys #{exp.keys-act.keys}. Actual map: #{act}" if (exp.keys-act.keys).count > 0
		exp.each do |k,exp_v|
			fail "For '#{k}' expected #{exp_v}, found #{act[k]}, model=#{model}" if act[k]!=exp_v
		end
	end

end