require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestOperations < Test::Unit::TestCase
 
  def test_symbol
    root = RubyMM.parse(':a')

    assert_right_class root, RubyMM::Symbol
    assert_equal 'a',root.name
  end

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

  def test_class_with_content
    root = RubyMM.parse("class AClass\nattr_accessor :name\nend")

    assert_right_class root, RubyMM::ClassDecl
    assert_equal nil,root.super_class
    assert_simple_const root.defname,'AClass'
    assert_equal 1,root.body.count
    assert_right_class root.body[0], RubyMM::Call
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

  def test_load_complex_file
    #Dir['../../**/*.rb'].each do |f|
    #  puts "#{f}"
    #  content = s = IO.read(f)
    #  root = RubyMM.parse(content)
    #end
    content = s = IO.read(File.dirname(__FILE__)+'/example_of_complex_class.rb.txt')
    root = RubyMM.parse(content)

    assert_right_class root, RubyMM::Block
    assert_equal 4, root.contents.count
    assert RubyMM.is_call(root.contents[0],'require',[RubyMM::string('helper')])
    assert RubyMM.is_call(root.contents[1],'require',[RubyMM::string('test/unit')])
    assert RubyMM.is_call(root.contents[2],'require',[RubyMM::string('rubymm')])
    def_of_TestOperations = root.contents[3]
    # check class, base class etc.
  end

  def assert_is_int(node,value)
  	assert node.is_a? RubyMM::IntLiteral
  	assert_equal value, node.value
  end

  def assert_is_str(node,value)
    assert node.is_a? RubyMM::StringLiteral
    assert_equal value, node.value
  end

  def assert_right_class(node,clazz)
  	assert node.is_a?(clazz), "Instead #{node.class}"
  end

  def assert_simple_const(node,name)
    assert_right_class node,RubyMM::Constant
    assert_equal name, node.name
    assert_equal nil, node.container
  end
 
end