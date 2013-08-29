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

	def test_multiple_assignment
	    root = RubyMM.parse('a,@b,c = 1,2,3')
	    assert_node root,RubyMM::MultipleAssignment
	    assert_equal 3,root.assignments.count
	    assert_node root.assignments[0], RubyMM::LocalVarAssignment,
	    	name_assigned:'a',
	    	value: RubyMM.int(1)
	    assert_node root.assignments[1], RubyMM::InstanceVarAssignment,
	    	name_assigned:'b',
	    	value: RubyMM.int(2)	   
	    assert_node root.assignments[2], RubyMM::LocalVarAssignment,
	    	name_assigned:'v',
	    	value: RubyMM.int(3)	   	    		    		    	
	end  

end