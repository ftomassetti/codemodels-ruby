$LOAD_PATH << File.expand_path( File.dirname(__FILE__) + '/../lib' )


module TestHelper

	def assert_is_int(node,value)
		assert node.is_a? RubyMM::IntLiteral
		assert_equal value, node.value
	end

	def assert_is_str(node,value)
		assert node.is_a? RubyMM::StringLiteral
		assert_equal value, node.value
	end

	def assert_right_class(node,clazz)
		assert node.is_a?(clazz), "Instead #{node.class}"
	end

	def assert_simple_const(node,name)
		assert_right_class node,RubyMM::Constant
		assert_equal name, node.name
		assert_equal nil, node.container
	end

	def assert_node(node,clazz,values)
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

end