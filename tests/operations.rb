require 'test/unit'
require 'parser'
require 'metamodel'
 
class TestOperations < Test::Unit::TestCase
 
  def test_sum
  	root = parse('3+40')

  	assert_right_class root, RubyMM::Call
  	assert_equal '+', root.name  	
  	assert_is_int root.receiver, 3
  	assert_equal 1,  root.args.count
  	assert_is_int root.args[0], 40
  end

  def test_fundef
  	root = parse("def somefunc \n 10\n end")

  	assert_right_class root, RubyMM::FunDef
  	assert_equal '+', root.name  	
  	assert_is_int root.receiver, 3
  	assert_equal 1,  root.args.count
  	assert_is_int root.args[0], 40
  end

  def assert_is_int(node,value)
  	assert node.is_a? RubyMM::IntLiteral
  	assert_equal value, node.value
  end

  def assert_right_class(node,clazz)
  	assert node.is_a?(clazz), "Instead #{node.class}"
  end
 
end