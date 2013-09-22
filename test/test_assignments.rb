require 'helper'
 
class TestAssignments < Test::Unit::TestCase

	include TestHelper
	include LightModels

	def test_op_assignement
		r = Ruby.parse("a.el ||= 2")
		assert_node r, Ruby::OperatorAssignment, value: Ruby.int(2), operator_name: '||', element_name: 'el'
		assert_node r.container, Ruby::Call
	end

end