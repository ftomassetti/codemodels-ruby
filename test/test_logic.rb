require 'helper'
 
class TestLogic < Test::Unit::TestCase

  include TestHelper
  include LightModels

  def test_and_symbol
    root = Ruby.parse('1 && 2')
    assert_node root, Ruby::AndOperator,
        #word_form: false,
        left: Ruby.int(1),
        right: Ruby.int(2)
   end

  def test_or_symbol
    root = Ruby.parse('1 || 2')
    assert_node root, Ruby::OrOperator,
        #word_form: false,
        left: Ruby.int(1),
        right: Ruby.int(2)
  end

  def test_and_word
    root = Ruby.parse('1 and 2')
    assert_node root, Ruby::AndOperator,
        #word_form: true,
        left: Ruby.int(1),
        right: Ruby.int(2)
   end

   def test_or_word
    root = Ruby.parse('1 or 2')
    assert_node root, Ruby::OrOperator,
        #word_form: true,
        left: Ruby.int(1),
        right: Ruby.int(2)
      end

    def test_or_local_assignement
      root = Ruby.parse('a||=1')
      assert_node root, Ruby::OrAssignment,
          assigned: Ruby::LocalVarAccess.build( { name: 'a' } ),
          value: Ruby.int(1)
    end

    def test_or_global_assignement
      root = Ruby.parse('$a||=1')
      assert_node root, Ruby::OrAssignment,
          assigned: Ruby::GlobalVarAccess.build( { name: 'a' } ),
          value: Ruby.int(1)
    end

    def test_or_instance_assignement
      root = Ruby.parse('@a||=1')
      assert_node root, Ruby::OrAssignment,
          assigned: Ruby::InstanceVarAccess.build( { name: 'a' } ),
          value: Ruby.int(1)
    end

  end