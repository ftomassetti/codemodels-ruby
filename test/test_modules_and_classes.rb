require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper

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
    assert_equal RubyMM.constant('Literal'),root.defname
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

  def test_module
    root = RubyMM.parse('module MyModule;end')

    assert_right_class root, RubyMM::ModuleDecl
    assert_equal 0,root.contents.count
  end

  def test_self
    root = RubyMM.parse('self')

    assert_node root, RubyMM::Self
  end

end