require 'helper'

require 'test/unit'
require 'ruby-lightmodels'

class TestConstants < Test::Unit::TestCase

	include TestHelper

	def test_const_decl
		root = RubyMM.parse("MODULE_NAME = 'test'")
		assert_node root,RubyMM::ConstantDecl,
		name:'MODULE_NAME', value: RubyMM.string('test')
	end

end