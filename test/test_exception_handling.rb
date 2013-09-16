require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestExceptionHandling < Test::Unit::TestCase

  include TestHelper
  include LightModels

  def test_rescue_empty
    root = Ruby.parse('begin;rescue;end')
    assert_node root, Ruby::BeginEndBlock,
        body: nil
    assert_equal 1,root.rescue_clauses.count
    assert_node root.rescue_clauses[0], Ruby::RescueClause,
        body: nil
   end

  def test_rescue_full
    root = Ruby.parse('begin;1;rescue;2;end')
    assert_node root, Ruby::BeginEndBlock,
        body: Ruby.int(1)
    assert_equal 1,root.rescue_clauses.count
    assert_node root.rescue_clauses[0], Ruby::RescueClause,
        body: Ruby.int(2)
  end

  def test_rescue_def_attached
    root = Ruby.parse('def a;1;rescue;2;end')
    assert_node root, Ruby::Def,
        body: Ruby.int(1)
    assert_equal 1,root.rescue_clauses.count
    assert_node root.rescue_clauses[0], Ruby::RescueClause,
        body: Ruby.int(2)
  end

end