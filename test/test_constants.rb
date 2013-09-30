require 'helper'

class TestConstants < Test::Unit::TestCase

	include TestHelper
	include CodeModels

	def test_const_decl
		root = Ruby.parse("MODULE_NAME = 'test'")
		assert_node root,Ruby::ConstantDecl,
		name:'MODULE_NAME', value: Ruby.string('test')
	end

end