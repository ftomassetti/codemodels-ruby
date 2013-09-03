require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper

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

  def test_empty_hash
    root = RubyMM.parse('{}')

    assert_right_class root, RubyMM::HashLiteral
    assert_equal 0, root.pairs.count
  end

  def test_hash_with_pairs
    root = RubyMM.parse('{ "a"=>1, "b"=>2}')

    assert_right_class root, RubyMM::HashLiteral
    assert_equal 2, root.pairs.count
    assert_node root.pairs[0], RubyMM::HashPair, 
        key: RubyMM.string('a'),
        value: RubyMM.int(1)
    assert_node root.pairs[1], RubyMM::HashPair, 
        key: RubyMM.string('b'),
        value: RubyMM.int(2)
  end

  def test_empty_array
    root = RubyMM.parse('[]')

    assert_right_class root, RubyMM::ArrayLiteral
    assert_equal 0, root.values.count
  end

  def test_array_with_values
    root = RubyMM.parse('[1,2]')

    assert_right_class root, RubyMM::ArrayLiteral
    assert_equal 2, root.values.count
    assert_is_int root.values[0], 1
    assert_is_int root.values[1], 2
  end

  def test_self_def
    root = RubyMM.parse('class A;def self.verbose;true;end;end')

    assert_right_class root,RubyMM::ClassDecl
    assert_node root.contents[0], RubyMM::Def, 
        onself: true,
        name: 'verbose',
        body: RubyMM::BooleanLiteral.build(true)
  end

  def test_return_empty
    root = RubyMM.parse('return')
    assert_node root,RubyMM::Return,
      value:nil
  end

  def test_return_value
    root = RubyMM.parse('return 1')
    assert_node root,RubyMM::Return,
      value: RubyMM.int(1)
  end

  def test_true_eq_true
    assert_equal true,RubyMM.bool(true)==RubyMM.bool(true)
  end

  def test_false_eq_false
    assert_equal true,RubyMM.bool(false)==RubyMM.bool(false)
  end

  def test_true_neq_false
    assert_equal false,RubyMM.bool(true)==RubyMM.bool(false)
  end

  # this and the following are more testing emf_jruby than this package...
  def test_eql_constants
    c1 = RubyMM.constant 'a','b','c'
    c2 = RubyMM.constant 'a','b','c'

    assert c1.eql?(c2)
    assert c2.eql?(c1)
    assert c1==c2
    assert c2==c1
  end

  def test_not_eql_constants
    c1 = RubyMM.constant 'a','b','c'
    c2 = RubyMM.constant 'a','d','c'

    assert (not (c1.eql?(c2)))
    assert (not (c2.eql?(c1)))
    assert (not (c1==c2))
    assert (not (c2==c1))
  end

  def test_call_to_super_with_no_params
    r = RubyMM.parse('def mymethod;super;end')

    call_to_super = r.body
    assert_node call_to_super,RubyMM::CallToSuper
    assert_equal 0,call_to_super.args.count
  end

  def test_global_scope_ref
    r = RubyMM.parse('::FooBar')

    assert_node r, RubyMM::GlobalScopeReference,
        name: 'FooBar'
  end

  def test_constant_through_global_scope_ref
    r = RubyMM.parse('::ActionView::MissingTemplate')

    assert_node r, RubyMM::Constant,
        name: 'MissingTemplate'
    assert_node r.container, RubyMM::GlobalScopeReference,
        name: 'ActionView'
  end

  def test_splat
    r = RubyMM.parse("a = *args").value
    assert_node r,RubyMM::Splat
    assert_node r.splatted, RubyMM::Call, name:'args'
  end

  def test_unary_minus
    r = RubyMM.parse('-a')
    assert_node r, RubyMM::UnaryOperation, operator_name: '-'
    assert_node r.value, RubyMM::Call, name:'a'
  end

  def test_regex_matcher
    r = RubyMM.parse('k =~ /^extra_/')

    assert_node r, RubyMM::RegexMatcher, regex: RubyMM::RegExpLiteral.build('^extra_')
    assert_node r.checked_value, RubyMM::Call, name: 'k'
  end

  def test_range
    r = RubyMM.parse('1..2')
    assert_node r, RubyMM::Range, lower: RubyMM.int(1), upper: RubyMM.int(2)
  end

  def test_yield
    r = RubyMM.parse('yield')
    assert_node r, RubyMM::YieldStatement
  end

  def test_def_with_ensure
    r = RubyMM.parse('def a;2;ensure;1;end')
    assert_node r, RubyMM::Def, body: RubyMM.int(2), ensure_body: RubyMM.int(1)
  end

  def test_next
    r = RubyMM.parse('next')
    assert_node r, RubyMM::NextStatement
  end

  def test_nth_group_ref
    r = RubyMM.parse('$1')
    assert_node r, RubyMM::NthGroupReference, n: 1
  end

  def test_super_call
    r = RubyMM.parse('super(1,2)')
    assert_node r, RubyMM::SuperCall, args: [RubyMM.int(1),RubyMM.int(2)]
  end

  def splatted_array
    splatted = RubyMM::Splat.new
    splatted.splatted = RubyMM::ArrayLiteral.new
    splatted
  end

  def test_args_cat_one
    r = RubyMM.parse('m(1,*[])')
    assert_equal [RubyMM.int(1),splatted_array], r.args
  end  

  def test_args_cat_two
    r = RubyMM.parse('m(1,2,*[])')
    assert_equal [RubyMM.int(1),RubyMM.int(2),splatted_array], r.args
  end  

  def test_args_push_one
    r = RubyMM.parse('m(*[],1)')
    assert_equal [splatted_array,RubyMM.int(1)], r.args
   end

  def test_args_push_two
    r = RubyMM.parse('m(*[],1,2)')
    assert_equal [splatted_array,RubyMM.int(1),RubyMM.int(2)], r.args
  end

  def test_args_cat_or_push_zero   
    r = RubyMM.parse('m(*[])')
    assert_equal [splatted_array], r.args
  end  

  def test_args_cat_and_push_two
    r = RubyMM.parse('m(1,2,*[],3,4)')
    assert_equal [RubyMM.int(1),RubyMM.int(2),splatted_array,RubyMM.int(3),RubyMM.int(4)],r.args
  end

end