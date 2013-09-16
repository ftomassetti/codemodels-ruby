require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper
  include LightModels
 
  def test_symbol
    root = Ruby.parse(':a')

    assert_right_class root, Ruby::Symbol
    assert_equal 'a',root.name
  end

  def test_false
    root = Ruby.parse('false')

    assert_right_class root, Ruby::BooleanLiteral
    assert_equal false,root.value
  end

  def test_dstring
    root = Ruby.parse("\"some string\"")

    assert_right_class root, Ruby::StringLiteral
    assert_equal 'some string', root.value
  end

  def test_dstring_with_value
    root = Ruby.parse('/^#{Regexp.escape(operator)}(.*)$/')

    assert_right_class root, Ruby::RegExpLiteral
    assert_equal 3, root.pieces.count
    assert_is_str root.pieces[0],'^'
    assert_is_str root.pieces[2],'(.*)$'
  end

  def test_dregexp_with_value
    root = Ruby.parse('"some #{val} string"')

    assert_right_class root, Ruby::StringLiteral
    assert_equal 3, root.pieces.count
    assert_is_str root.pieces[0],'some '
    assert_is_str root.pieces[2],' string'
  end

  def test_true
    root = Ruby.parse('true')

    assert_right_class root, Ruby::BooleanLiteral
    assert_equal true,root.value
  end

  def test_nil
    root = Ruby.parse('nil')

    assert_right_class root, Ruby::NilLiteral
  end

  def test_float
    root = Ruby.parse('12.3')

    assert_node root,Ruby::FloatLiteral,
      value: 12.3
  end

  def test_regexp
    root = Ruby.parse'/^[a-z]*/'

    assert_node root,Ruby::RegExpLiteral,
      value: '^[a-z]*'
  end

  def test_cmd_line_str
    root = Ruby.parse '`svn info --xml #{path}`'

    assert_right_class root, Ruby::CmdLineStringLiteral
    assert_equal 2, root.pieces.count
    assert_is_str root.pieces[0],'svn info --xml '
    assert_node root.pieces[1], Ruby::Call, name:'path'
  end

  def test_dynamic_symbol
    root = Ruby.parse ':"cf_#{visible_field.id}"'

    assert_right_class root, Ruby::DynamicSymbol
    assert_equal 2, root.pieces.count
    assert_is_str root.pieces[0],'cf_'
    assert_node root.pieces[1], Ruby::Call, name:'id'    
  end

 end