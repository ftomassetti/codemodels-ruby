require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestOperations < Test::Unit::TestCase

 include TestHelper
 include RubyMM

  def test_load_complex_file

    content = IO.read(File.dirname(__FILE__)+'/example_of_complex_class.rb.txt')
    root = RubyMM.parse(content)

    assert_right_class root, RubyMM::Block
    assert_equal 4, root.contents.count
    assert RubyMM.is_call(root.contents[0],'require',[RubyMM::string('helper')])
    assert RubyMM.is_call(root.contents[1],'require',[RubyMM::string('test/unit')])
    assert RubyMM.is_call(root.contents[2],'require',[RubyMM::string('rubymm')])
    def_of_TestOperations = root.contents[3]
    
    # class TestOperations
    assert_right_class def_of_TestOperations, RubyMM::ClassDecl
    assert_equal RubyMM.constant('Test','Unit','TestCase'),def_of_TestOperations.super_class
    assert_equal 19,def_of_TestOperations.contents.count

    # TestOperations test_symbol
    t_symbol = def_of_TestOperations.contents[0]
    assert RubyMM.is_def(t_symbol,'test_symbol')
    assert_equal 3,t_symbol.body.contents.count

    st = t_symbol.body.contents[0]
    assert_right_class st, RubyMM::LocalVarAssignment
    assert_equal 'root',st.name_assigned
   	assert_node st.value, Call, name: 'parse', 
   			args: [RubyMM.string(':a')], 
   			implicit_receiver: false, 
   			receiver: RubyMM.constant('RubyMM')

    st = t_symbol.body.contents[1]
    assert_node st, Call, name: 'assert_right_class', 
        args: [LocalVarAccess.build('root'),RubyMM.constant('RubyMM','Symbol')], 
        implicit_receiver: true, 
        receiver: nil

    st = t_symbol.body.contents[2]
    call_root_name = Call.build name: 'name', args: [], receiver: LocalVarAccess.build('root'), implicit_receiver: false
    assert_node st, Call, name: 'assert_equal', 
        args: [RubyMM.string('a'),call_root_name], 
        implicit_receiver: true, 
        receiver: nil
  end

 end