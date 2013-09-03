require 'helper'

require 'test/unit'
require 'ruby-lightmodels'

class TestOperations < Test::Unit::TestCase

	include TestHelper

	def test_constant_top_container_single
		a = RubyMM.constant('a')

		assert a.top_container == nil
	end

	def test_constant_top_container_double
		ab = RubyMM.constant('a','b')

		assert_equal 'a',ab.top_container.name
	end

	def test_constant_top_container_triple
		abc = RubyMM.constant('a','b','c')

		assert_equal 'a',abc.top_container.name
	end

	def test_constant_single
		a = RubyMM.constant('a')

		assert_right_class a, RubyMM::Constant
		assert_equal 'a',a.name
		assert a.container==nil
	end

	def test_constant_double
		ab = RubyMM.constant('a','b')

		assert_right_class ab, RubyMM::Constant
		assert_equal 'b',ab.name
		
		a = ab.container
		assert_right_class a, RubyMM::Constant
		assert_equal 'a',a.name
		assert a.container==nil
	end

	def test_constant_triple
		abc = RubyMM.constant('a','b','c')

		assert_right_class abc, RubyMM::Constant
		assert_equal 'c',abc.name
		
		ab = abc.container
		assert_right_class ab, RubyMM::Constant
		assert_equal 'b',ab.name
		
		a = ab.container
		assert_right_class a, RubyMM::Constant
		assert_equal 'a',a.name
		assert a.container==nil
	end

end