require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestNotVariableAssignement < Test::Unit::TestCase

  include TestHelper

  def test_element_assignment
    root = RubyMM.parse('models[1] = 2')
    assert_node root,RubyMM::ElementAssignement,
        container: RubyMM::Call.build(name:'models',implicit_receiver:false),
        element: RubyMM.int(1),
        value: RubyMM.int(2)
  end

  def test_element_plus_assignment
    root = RubyMM.parse('models[1] += 2')
    assert_node root,RubyMM::ElementOperationAssignement,
        container: RubyMM::Call.build(name:'models',implicit_receiver:false),
        element: RubyMM.int(1),
        value: RubyMM.int(2),
        operator:'+'
  end

  def test_element_minus_assignment
    root = RubyMM.parse('models[1] -= 2')
    assert_node root,RubyMM::ElementOperationAssignement,
        container: RubyMM::Call.build(name:'models',implicit_receiver:false),
        element: RubyMM.int(1),
        value: RubyMM.int(2),
        operator:'-'
  end  

  def test_element_mul_assignment
    root = RubyMM.parse('models[1] *= 2')
    assert_node root,RubyMM::ElementOperationAssignement,
        container: RubyMM::Call.build(name:'models',implicit_receiver:false),
        element: RubyMM.int(1),
        value: RubyMM.int(2),
        operator:'*'
  end

   def test_element_div_assignment
    root = RubyMM.parse('models[1] /= 2')
    assert_node root,RubyMM::ElementOperationAssignement,
        container: RubyMM::Call.build(name:'models',implicit_receiver:false),
        element: RubyMM.int(1),
        value: RubyMM.int(2),
        operator:'/'
  end  

end