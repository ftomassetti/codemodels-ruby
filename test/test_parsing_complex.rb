require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestOperations < Test::Unit::TestCase

 include TestHelper

  def test_load_complex_file
    content = IO.read(File.dirname(__FILE__)+'/example_of_complex_class.rb.txt')
    root = RubyMM.parse(content)

    assert_right_class root, RubyMM::Block
    assert_equal 4, root.contents.count
    assert RubyMM.is_call(root.contents[0],'require',[RubyMM::string('helper')])
    assert RubyMM.is_call(root.contents[1],'require',[RubyMM::string('test/unit')])
    assert RubyMM.is_call(root.contents[2],'require',[RubyMM::string('rubymm')])
    def_of_TestOperations = root.contents[3]
    # check class, base class etc.
    assert_right_class def_of_TestOperations, RubyMM::ClassDecl
  end

 end