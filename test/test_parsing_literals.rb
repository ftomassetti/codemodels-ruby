require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper
 
  def test_symbol
    root = RubyMM.parse(':a')

    assert_right_class root, RubyMM::Symbol
    assert_equal 'a',root.name
  end

    def test_false
    root = RubyMM.parse('false')

    assert_right_class root, RubyMM::BooleanLiteral
    assert_equal false,root.value
  end

  def test_dstring
    root = RubyMM.parse("\"some string\"")

    assert_right_class root, RubyMM::StringLiteral
    assert_equal 'some string', root.value
  end

  def test_dstring_with_value
    root = RubyMM.parse('/^#{Regexp.escape(operator)}(.*)$/')

    assert_right_class root, RubyMM::RegExpLiteral
    assert_equal 3, root.pieces.count
    assert_is_str root.pieces[0],'^'
    assert_is_str root.pieces[2],'(.*)$'
  end

  def test_dregexp_with_value
    root = RubyMM.parse('"some #{val} string"')

    assert_right_class root, RubyMM::StringLiteral
    assert_equal 3, root.pieces.count
    assert_is_str root.pieces[0],'some '
    assert_is_str root.pieces[2],' string'
  end

  def test_true
    root = RubyMM.parse('true')

    assert_right_class root, RubyMM::BooleanLiteral
    assert_equal true,root.value
  end

  def test_nil
    root = RubyMM.parse('nil')

    assert_right_class root, RubyMM::NilLiteral
  end

  def test_float
    root = RubyMM.parse('12.3')

    assert_node root,RubyMM::FloatLiteral,
      value: 12.3
  end

  def test_regexp
    root = RubyMM.parse'/^[a-z]*/'

    assert_node root,RubyMM::RegExpLiteral,
      value: '^[a-z]*'
  end

 end