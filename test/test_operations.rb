require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestOperations < Test::Unit::TestCase
 
  def test_sum
  	root = RubyMM.parse('3+40')

  	assert_right_class root, RubyMM::Call
  	assert_equal '+', root.name  	
  	assert_is_int root.receiver, 3
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

  def assert_is_int(node,value)
  	assert node.is_a? RubyMM::IntLiteral
  	assert_equal value, node.value
  end

  def assert_right_class(node,clazz)
  	assert node.is_a?(clazz), "Instead #{node.class}"
  end
 
end