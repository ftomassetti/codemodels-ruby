require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

 include TestHelper
 include LightModels
 include LightModels::Ruby

  def test_load_complex_file

    content = IO.read(File.dirname(__FILE__)+'/example_of_complex_class.rb.txt')
    root = Ruby.parse(content)

    assert_right_class root, Ruby::Block
    assert_equal 4, root.contents.count
    assert Ruby.is_call(root.contents[0],'require',[Ruby::string('helper')])
    assert Ruby.is_call(root.contents[1],'require',[Ruby::string('test/unit')])
    assert Ruby.is_call(root.contents[2],'require',[Ruby::string('ruby-lightmodels')])
    def_of_TestOperations = root.contents[3]
    
    # class TestOperations
    assert_right_class def_of_TestOperations, Ruby::ClassDecl
    assert_equal Ruby.constant('Test','Unit','TestCase'),def_of_TestOperations.super_class
    assert_equal 19,def_of_TestOperations.contents.count

    # TestOperations test_symbol
    t_symbol = def_of_TestOperations.contents[0]
    assert Ruby.is_def(t_symbol,'test_symbol')
    assert_equal 3,t_symbol.body.contents.count

    st = t_symbol.body.contents[0]
    assert_right_class st, Ruby::LocalVarAssignment
    assert_equal 'root',st.name_assigned
   	assert_node st.value, ExplicitReceiverCall, name: 'parse', 
   			args: [Ruby.string(':a')], 
   			receiver: Ruby.constant('Ruby')

    st = t_symbol.body.contents[1]
    assert_node st, ImplicitReceiverCall, name: 'assert_right_class', 
        args: [LocalVarAccess.build('root'),Ruby.constant('Ruby','Symbol')], 
        receiver: nil

    st = t_symbol.body.contents[2]
    call_root_name = ImplicitReceiverCall.build name: 'name', args: [], receiver: LocalVarAccess.build('root'),
        args: [Ruby.string('a'),call_root_name], 
        receiver: nil
  end

 end