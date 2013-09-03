require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestAssignments < Test::Unit::TestCase

	include TestHelper

	def test_op_assignement
		r = RubyMM.parse("a.el ||= 2")
		assert_node r, RubyMM::OperatorAssignment, value: RubyMM.int(2), operator_name: '||', element_name: 'el'
		assert_node r.container, RubyMM::Call
	end

end