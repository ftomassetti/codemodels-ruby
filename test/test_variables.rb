require 'helper'

class TestVariables < Test::Unit::TestCase

	include TestHelper
	include LightModels

	def test_inst_var_access
		root = Ruby.parse('@v')
		assert_node root,Ruby::InstanceVarAccess,
		name:'v'
	end

	def test_inst_var_assignment
		root = Ruby.parse('@v = 1')
		assert_node root, Ruby::InstanceVarAssignment,
		name_assigned: 'v',
		value: Ruby.int(1)
	end

	def test_local_var_access
		root = Ruby.parse('v=10;v')
		assert_node root.contents[1],Ruby::LocalVarAccess,
		name:'v'
	end

	def test_local_var_assign
		root = Ruby.parse('some_var = 10')

		assert_right_class root, Ruby::LocalVarAssignment
		assert_equal 'some_var',root.name_assigned
		assert_is_int root.value, 10
	end

	def test_global_var_access
		root = Ruby.parse('$v')

		assert_right_class root, Ruby::GlobalVarAccess
		assert_equal 'v',root.name
	end

	def test_global_var_assignement
		root = Ruby.parse('$v = 10')

		assert_right_class root, Ruby::GlobalVarAssignment
		assert_equal 'v',root.name_assigned
		assert_is_int root.value, 10
	end

	def test_class_var_access
		root = Ruby.parse('@@v')

		assert_right_class root, Ruby::ClassVarAccess
		assert_equal 'v',root.name
	end

	def test_class_var_assignement
		root = Ruby.parse('@@v = 10')

		assert_right_class root, Ruby::ClassVarAssignment
		assert_equal 'v',root.name_assigned
		assert_is_int root.value, 10
	end

	def test_block_var_access
		root = Ruby.parse('[].each {|x| x}')

  		code_block = root.block_arg
  		assert_node code_block.body, Ruby::BlockVarAccess,
  		name:'x'
	end

	def test_block_var_assignement
		root = Ruby.parse('[].each {|x| x=1}')

  		code_block = root.block_arg
  		assert_node code_block.body, Ruby::BlockVarAssignment,
  		{ name_assigned:'x', value: Ruby::IntLiteral.build(1) }
	end

end