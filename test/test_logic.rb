require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestLogic < Test::Unit::TestCase

  include TestHelper

  def test_and_symbol
    root = RubyMM.parse('1 && 2')
    assert_node root, RubyMM::AndOperator,
        #word_form: false,
        left: RubyMM.int(1),
        right: RubyMM.int(2)
   end

  def test_or_symbol
    root = RubyMM.parse('1 || 2')
    assert_node root, RubyMM::OrOperator,
        #word_form: false,
        left: RubyMM.int(1),
        right: RubyMM.int(2)
  end

  def test_and_word
    root = RubyMM.parse('1 and 2')
    assert_node root, RubyMM::AndOperator,
        #word_form: true,
        left: RubyMM.int(1),
        right: RubyMM.int(2)
   end

   def test_or_word
    root = RubyMM.parse('1 or 2')
    assert_node root, RubyMM::OrOperator,
        #word_form: true,
        left: RubyMM.int(1),
        right: RubyMM.int(2)
      end

    def test_or_local_assignement
      root = RubyMM.parse('a||=1')
      assert_node root, RubyMM::OrAssignment,
          assigned: RubyMM::LocalVarAccess.build( { name: 'a' } ),
          value: RubyMM.int(1)
    end

    def test_or_global_assignement
      root = RubyMM.parse('$a||=1')
      assert_node root, RubyMM::OrAssignment,
          assigned: RubyMM::GlobalVarAccess.build( { name: 'a' } ),
          value: RubyMM.int(1)
    end

    def test_or_instance_assignement
      root = RubyMM.parse('@a||=1')
      assert_node root, RubyMM::OrAssignment,
          assigned: RubyMM::InstanceVarAccess.build( { name: 'a' } ),
          value: RubyMM.int(1)
    end

  end