require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestNotVariableAssignment < Test::Unit::TestCase

  include TestHelper
  include LightModels

  def test_element_assignment
    root = Ruby.parse('models[1] = 2')
    assert_node root,Ruby::ElementAssignment,
        container: Ruby::Call.build(name:'models',implicit_receiver:false),
        element: Ruby.int(1),
        value: Ruby.int(2)
  end

  def test_element_plus_assignment
    root = Ruby.parse('models[1] += 2')
    assert_node root,Ruby::ElementOperationAssignment,
        container: Ruby::Call.build(name:'models',implicit_receiver:false),
        element: Ruby.int(1),
        value: Ruby.int(2),
        operator:'+'
  end

  def test_element_minus_assignment
    root = Ruby.parse('models[1] -= 2')
    assert_node root,Ruby::ElementOperationAssignment,
        container: Ruby::Call.build(name:'models',implicit_receiver:false),
        element: Ruby.int(1),
        value: Ruby.int(2),
        operator:'-'
  end  

  def test_element_mul_assignment
    root = Ruby.parse('models[1] *= 2')
    assert_node root,Ruby::ElementOperationAssignment,
        container: Ruby::Call.build(name:'models',implicit_receiver:false),
        element: Ruby.int(1),
        value: Ruby.int(2),
        operator:'*'
  end

   def test_element_div_assignment
    root = Ruby.parse('models[1] /= 2')
    assert_node root,Ruby::ElementOperationAssignment,
        container: Ruby::Call.build(name:'models',implicit_receiver:false),
        element: Ruby.int(1),
        value: Ruby.int(2),
        operator:'/'
  end  

	def test_multiple_assignment_to_values
	    root = Ruby.parse('a,@b,c = 1,2,3')
	    assert_node root,Ruby::MultipleAssignment
	    assert_equal 3,root.assignments.count
	    assert_node root.assignments[0], Ruby::LocalVarAssignment,
	    	name_assigned:'a',
	    	value: nil
	    assert_node root.assignments[1], Ruby::InstanceVarAssignment,
	    	name_assigned:'b',
	    	value: nil
	    assert_node root.assignments[2], Ruby::LocalVarAssignment,
	    	name_assigned:'c',
	    	value: nil
      assert_equal [Ruby.int(1),Ruby.int(2),Ruby.int(3)],root.values	   	    		    		    	
	end  

  def test_multiple_assignment_to_call
    root = Ruby.parse('@auth_source_pages, @auth_sources = paginate AuthSource, :per_page => 25')
    assert_node root,Ruby::MultipleAssignment
    assert_equal 1,root.values.count
    assert_node root.values[0], Ruby::Call, name: 'paginate'
  end

end