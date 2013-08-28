require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestExceptionHandling < Test::Unit::TestCase

  include TestHelper

  # def test_beginrescue_recognized
  #   root = RubyMM.parse("begin\nrescue\nend")
  
  #   assert_right_class root, RubyMM::BeginRescue
  # end

  # def test_beginrescue_body
  #   root = RubyMM.parse("begin\n@a\n@b\nrescue\nend")
  
  #   assert_right_class root, RubyMM::BeginRescue

  # end

  def test_rescue_empty
    root = RubyMM.parse('begin;rescue;end')
    assert_node root, RubyMM::BeginEndBlock,
        body: nil
    assert_equal 1,root.rescue_clauses.count
    assert_node root.rescue_clauses[0], RubyMM::RescueClause,
        body: nil
   end

  def test_rescue_full
    root = RubyMM.parse('begin;1;rescue;2;end')
    assert_node root, RubyMM::BeginEndBlock,
        body: RubyMM.int(1)
    assert_equal 1,root.rescue_clauses.count
    assert_node root.rescue_clauses[0], RubyMM::RescueClause,
        body: RubyMM.int(2)
  end

  def test_rescue_def_attached
    root = RubyMM.parse('def a;1;rescue;2;end')
    assert_node root, RubyMM::Def,
        body: RubyMM.int(1)
    assert_equal 1,root.rescue_clauses.count
    assert_node root.rescue_clauses[0], RubyMM::RescueClause,
        body: RubyMM.int(2)
  end

end