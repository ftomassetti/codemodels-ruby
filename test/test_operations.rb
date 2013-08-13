require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper

  def test_sum
  	root = RubyMM.parse('3+40')

  	assert_right_class root, RubyMM::Call
  	assert_equal '+', root.name  	
  	assert_is_int root.receiver, 3
    assert_equal false, root.implicit_receiver
  	assert_equal 1,  root.args.count
  	assert_is_int root.args[0], 40
  end

  def test_def_with_some_statements
    root = RubyMM.parse("def somefunc \n 1\n 2\n 3\n end")

    assert_right_class root, RubyMM::Def
    assert_equal 'somefunc', root.name        
    assert root.body.is_a? RubyMM::Block
    assert_equal 3,root.body.contents.count
    assert_is_int root.body.contents[0], 1
    assert_is_int root.body.contents[1], 2
    assert_is_int root.body.contents[2], 3
  end

  def test_def_with_one_statements
  	root = RubyMM.parse("def somefunc \n 10\n end")

  	assert_right_class root, RubyMM::Def
  	assert_equal 'somefunc', root.name  	
    assert_is_int root.body, 10
  end

  def test_require
    root = RubyMM.parse("require 'something'")

    assert_right_class root, RubyMM::Call
    assert_equal 'require', root.name
    assert_equal true, root.implicit_receiver
    assert_equal 1, root.args.count
    assert_is_str root.args[0],'something'   
  end

  def test_class_decl_ext_class_in_module
    root = RubyMM.parse("class TestOperations < Test::Unit::TestCase\nend")
  
    assert_right_class root, RubyMM::ClassDecl
    assert_right_class root.super_class,RubyMM::Constant
    assert_equal 'TestCase', root.super_class.name
    assert_right_class root.super_class.container,RubyMM::Constant
    assert_equal 'Unit', root.super_class.container.name
    assert_right_class root.super_class.container.container,RubyMM::Constant
    assert_equal 'Test', root.super_class.container.container.name
    assert_equal nil, root.super_class.container.container.container
  end

  def test_class_decl_ext_class_simple
    root = RubyMM.parse("class Literal < Value\nend")

    assert_right_class root, RubyMM::ClassDecl
    assert_equal 'Value', root.super_class.name
    assert_equal nil,root.super_class.container
  end

  def test_class_decl_no_ext
    root = RubyMM.parse("class Literal\nend")

    assert_right_class root, RubyMM::ClassDecl
    assert_equal nil,root.super_class
  end

  def test_class_with_nil_content
    root = RubyMM.parse("class Literal\nnil\nend")

    assert_right_class root, RubyMM::ClassDecl
    assert_equal 1,root.contents.count
    assert_right_class root.contents[0],RubyMM::NilLiteral
  end

  def test_class_with_content
    root = RubyMM.parse("class AClass\nattr_accessor :name\nend")

    assert_right_class root, RubyMM::ClassDecl
    assert_equal nil,root.super_class
    assert_simple_const root.defname,'AClass'
    assert_equal 1,root.contents.count
    assert_right_class root.contents[0], RubyMM::Call
  end

  def test_local_var_assign
    root = RubyMM.parse('some_var = 10')

    assert_right_class root, RubyMM::LocalVarAssignment
    assert_equal 'some_var',root.name_assigned
    assert_is_int root.value, 10
  end

  def test_global_var_access
    root = RubyMM.parse('$v')

    assert_right_class root, RubyMM::GlobalVarAccess
    assert_equal 'v',root.name
  end

  def test_global_var_assignement
    root = RubyMM.parse('$v = 10')

    assert_right_class root, RubyMM::GlobalVarAssignment
    assert_equal 'v',root.name_assigned
    assert_is_int root.value, 10
  end

  def test_empty_hash
    root = RubyMM.parse('{}')

    assert_right_class root, RubyMM::HashLiteral
    assert_equal 0, root.pairs.count
  end

  def test_hash_with_pairs
    root = RubyMM.parse('{ "a"=>1, "b"=>2}')

    assert_right_class root, RubyMM::HashLiteral
    assert_equal 2, root.pairs.count
    assert_node root.pairs[0], RubyMM::HashPair, 
        key: RubyMM.string('a'),
        value: RubyMM.int(1)
    assert_node root.pairs[1], RubyMM::HashPair, 
        key: RubyMM.string('b'),
        value: RubyMM.int(2)
  end

  def test_empty_array
    root = RubyMM.parse('[]')

    assert_right_class root, RubyMM::ArrayLiteral
    assert_equal 0, root.values.count
  end

  def test_array_with_values
    root = RubyMM.parse('[1,2]')

    assert_right_class root, RubyMM::ArrayLiteral
    assert_equal 2, root.values.count
    assert_is_int root.values[0], 1
    assert_is_int root.values[1], 2
  end
 
end