require 'helper'

require 'test/unit'
require 'rubymm'

class TestVariables < Test::Unit::TestCase

	include TestHelper

	def test_inst_var_access
		root = RubyMM.parse('@v')
		assert_node root,RubyMM::InstanceVarAccess,
		name:'v'
	end

	def test_inst_var_assignment
		root = RubyMM.parse('@v = 1')
		assert_node root, RubyMM::InstanceVarAssignment,
		name_assigned: 'v',
		value: RubyMM.int(1)
	end

	def test_local_var_access
		root = RubyMM.parse('v=10;v')
		assert_node root.contents[1],RubyMM::LocalVarAccess,
		name:'v'
	end

	def test_local_var_assign
		root = RubyMM.parse('some_var = 10')

		assert_right_class root, RubyMM::LocalVarAssignment
		assert_equal 'some_var',root.name_assigned
		assert_is_int root.value, 10
	end

	def test_global_var_access
		root = RubyMM.parse('$v')

		assert_right_class root, RubyMM::GlobalVarAccess
		assert_equal 'v',root.name
	end

	def test_global_var_assignement
		root = RubyMM.parse('$v = 10')

		assert_right_class root, RubyMM::GlobalVarAssignment
		assert_equal 'v',root.name_assigned
		assert_is_int root.value, 10
	end

	def test_class_var_access
		root = RubyMM.parse('@@v')

		assert_right_class root, RubyMM::ClassVarAccess
		assert_equal 'v',root.name
	end

	def test_class_var_assignement
		root = RubyMM.parse('@@v = 10')

		assert_right_class root, RubyMM::ClassVarAssignment
		assert_equal 'v',root.name_assigned
		assert_is_int root.value, 10
	end

	def test_block_var_access
		root = RubyMM.parse('[].each {|x| x}')

  		code_block = root.block_arg
  		assert_node code_block.body, RubyMM::BlockVarAccess,
  		name:'x'
	end

	def test_block_var_assignement
		root = RubyMM.parse('[].each {|x| x=1}')

  		code_block = root.block_arg
  		assert_node code_block.body, RubyMM::BlockVarAssignment,
  		{ name_assigned:'x', value: RubyMM::IntLiteral.build(1) }
	end

end