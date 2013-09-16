require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper
  include LightModels

  def test_sum
    root = Ruby.parse('3+40')

    assert_right_class root, Ruby::ExplicitReceiverCall
    assert_equal '+', root.name   
    assert_is_int root.receiver, 3
    assert_equal 1,  root.args.count
    assert_is_int root.args[0], 40
  end

  def test_def_with_some_statements
    root = Ruby.parse("def somefunc \n 1\n 2\n 3\n end")

    assert_right_class root, Ruby::Def
    assert_equal 'somefunc', root.name        
    assert root.body.is_a? Ruby::Block
    assert_equal 3,root.body.contents.count
    assert_is_int root.body.contents[0], 1
    assert_is_int root.body.contents[1], 2
    assert_is_int root.body.contents[2], 3
  end

  def test_def_with_one_statements
    root = Ruby.parse("def somefunc \n 10\n end")

    assert_right_class root, Ruby::Def
    assert_equal 'somefunc', root.name    
    assert_is_int root.body, 10
  end

  def test_require
    root = Ruby.parse("require 'something'")

    assert_right_class root, Ruby::ImplicitReceiverCall
    assert_equal 'require', root.name
    assert_equal 1, root.args.count
    assert_is_str root.args[0],'something'   
  end

  def test_empty_hash
    root = Ruby.parse('{}')

    assert_right_class root, Ruby::HashLiteral
    assert_equal 0, root.pairs.count
  end

  def test_hash_with_pairs
    root = Ruby.parse('{ "a"=>1, "b"=>2}')

    assert_right_class root, Ruby::HashLiteral
    assert_equal 2, root.pairs.count
    assert_node root.pairs[0], Ruby::HashPair, 
        key: Ruby.string('a'),
        value: Ruby.int(1)
    assert_node root.pairs[1], Ruby::HashPair, 
        key: Ruby.string('b'),
        value: Ruby.int(2)
  end

  def test_empty_array
    root = Ruby.parse('[]')

    assert_right_class root, Ruby::ArrayLiteral
    assert_equal 0, root.values.count
  end

  def test_array_with_values
    root = Ruby.parse('[1,2]')

    assert_right_class root, Ruby::ArrayLiteral
    assert_equal 2, root.values.count
    assert_is_int root.values[0], 1
    assert_is_int root.values[1], 2
  end

  def test_self_def
    root = Ruby.parse('class A;def self.verbose;true;end;end')

    assert_right_class root,Ruby::ClassDecl
    assert_node root.contents[0], Ruby::SelfDef, 
        name: 'verbose',
        body: Ruby::BooleanLiteral.build(true)
  end

  def test_return_empty
    root = Ruby.parse('return')
    assert_node root,Ruby::Return,
      value:nil
  end

  def test_return_value
    root = Ruby.parse('return 1')
    assert_node root,Ruby::Return,
      value: Ruby.int(1)
  end

  def test_true_eq_true
    assert_equal true,Ruby.bool(true)==Ruby.bool(true)
  end

  def test_false_eq_false
    assert_equal true,Ruby.bool(false)==Ruby.bool(false)
  end

  def test_true_neq_false
    assert_equal false,Ruby.bool(true)==Ruby.bool(false)
  end

  # this and the following are more testing emf_jruby than this package...
  def test_eql_constants
    c1 = Ruby.constant 'a','b','c'
    c2 = Ruby.constant 'a','b','c'

    assert c1.eql?(c2)
    assert c2.eql?(c1)
    assert c1==c2
    assert c2==c1
  end

  def test_not_eql_constants
    c1 = Ruby.constant 'a','b','c'
    c2 = Ruby.constant 'a','d','c'

    assert (not (c1.eql?(c2)))
    assert (not (c2.eql?(c1)))
    assert (not (c1==c2))
    assert (not (c2==c1))
  end

  def test_call_to_super_with_no_params
    r = Ruby.parse('def mymethod;super;end')

    call_to_super = r.body
    assert_node call_to_super,Ruby::CallToSuper
    assert_equal 0,call_to_super.args.count
  end

  def test_global_scope_ref
    r = Ruby.parse('::FooBar')

    assert_node r, Ruby::GlobalScopeReference,
        name: 'FooBar'
  end

  def test_constant_through_global_scope_ref
    r = Ruby.parse('::ActionView::MissingTemplate')

    assert_node r, Ruby::Constant,
        name: 'MissingTemplate'
    assert_node r.container, Ruby::GlobalScopeReference,
        name: 'ActionView'
  end

  def test_splat
    r = Ruby.parse("a = *args").value
    assert_node r,Ruby::Splat
    assert_node r.splatted, Ruby::Call, name:'args'
  end

  def test_unary_minus
    r = Ruby.parse('-a')
    assert_node r, Ruby::UnaryOperation, operator_name: '-'
    assert_node r.value, Ruby::Call, name:'a'
  end

  def test_retry
    r = Ruby.parse('retry')
    assert_node r, Ruby::RetryStatement
  end

  def test_regex_matcher
    r = Ruby.parse('k =~ /^extra_/')

    assert_node r, Ruby::RegexMatcher, regex: Ruby::RegExpLiteral.build('^extra_')
    assert_node r.checked_value, Ruby::Call, name: 'k'
  end

  def test_regex_tryer
    r = Ruby.parse('/^extra_/ =~ k')

    assert_node r, Ruby::RegexTryer, regex: Ruby::RegExpLiteral.build('^extra_')
    assert_node r.checked_value, Ruby::Call, name: 'k'
  end

  def test_range
    r = Ruby.parse('1..2')
    assert_node r, Ruby::Range, lower: Ruby.int(1), upper: Ruby.int(2)
  end

  def test_yield
    r = Ruby.parse('yield')
    assert_node r, Ruby::YieldStatement
  end

  def test_def_with_ensure
    r = Ruby.parse('def a;2;ensure;1;end')
    assert_node r, Ruby::Def, body: Ruby.int(2), ensure_body: Ruby.int(1)
  end

  def test_def_on_self_with_block_and_ensure
    code = "def self.with_deliveries(enabled = true, &block)
      was_enabled = ActionMailer::Base.perform_deliveries
      ActionMailer::Base.perform_deliveries = !!enabled
      yield
    ensure
      ActionMailer::Base.perform_deliveries = was_enabled
    end"
    r = Ruby.parse(code)
    assert_node r, Ruby::Def, name:'with_deliveries'
    assert_not_nil r.ensure_body
    assert_node r.ensure_body, Ruby::VarAssignment
  end

  def test_begin_ensure_block
    r = Ruby.parse('begin;1;ensure;2;end')
    assert_node r,Ruby::BeginEndBlock, body: Ruby.int(1), ensure_body: Ruby.int(2)
  end

  def test_next
    r = Ruby.parse('next')
    assert_node r, Ruby::NextStatement
  end

  def test_nth_group_ref
    r = Ruby.parse('$1')
    assert_node r, Ruby::NthGroupReference, n: 1
  end

  def test_back_ref
    r = Ruby.parse('$&')
    assert_node r, Ruby::BackReference
  end

  def test_super_call
    r = Ruby.parse('super(1,2)')
    assert_node r, Ruby::SuperCall, args: [Ruby.int(1),Ruby.int(2)]
  end

  def test_argscat_at_the_end_after_three
    r = Ruby.parse('link_to(name, options, html_options, *parameters_for_method_reference)')

    assert_equal 4,r.args.count
    assert_node r.args[0], Ruby::Call, name: 'name'
    assert_node r.args[1], Ruby::Call, name: 'options'
    assert_node r.args[2], Ruby::Call, name: 'html_options'
    assert_node r.args[3], Ruby::Splat
    assert_node r.args[3].splatted, Ruby::Call, name: 'parameters_for_method_reference'
  end

   def test_argspush_at_the_beginning_before_three
    r = Ruby.parse('link_to(*parameters_for_method_reference, name, options, html_options)')

    assert_equal 4,r.args.count
    assert_node r.args[1], Ruby::Call, name: 'name'
    assert_node r.args[2], Ruby::Call, name: 'options'
    assert_node r.args[3], Ruby::Call, name: 'html_options'
    assert_node r.args[0], Ruby::Splat
    assert_node r.args[0].splatted, Ruby::Call, name: 'parameters_for_method_reference'
  end 

  def test_argscat_on_empty_array_at_the_end_after_three
    r = Ruby.parse('link_to(name, options, html_options, *[])')

    assert_equal 4,r.args.count
    assert_node r.args[0], Ruby::Call, name: 'name'
    assert_node r.args[1], Ruby::Call, name: 'options'
    assert_node r.args[2], Ruby::Call, name: 'html_options'
    assert_node r.args[3], Ruby::Splat
    assert_node r.args[3].splatted, Ruby::ArrayLiteral
  end

  def test_argspush_on_empty_array_at_the_beginning_before_three
    r = Ruby.parse('link_to(*[], name, options, html_options)')

    assert_equal 4,r.args.count
    assert_node r.args[1], Ruby::Call, name: 'name'
    assert_node r.args[2], Ruby::Call, name: 'options'
    assert_node r.args[3], Ruby::Call, name: 'html_options'
    assert_node r.args[0], Ruby::Splat
    assert_node r.args[0].splatted, Ruby::ArrayLiteral
  end

  def test_five_before_and_after_splat_arg
    r = Ruby.parse('link_to(0,1,2,3,4,*5,6,7,8,9,10)')
    assert_equal 11,r.args.count
    assert_equal r.args[0], Ruby.int(0)
    assert_equal r.args[1], Ruby.int(1)
    assert_equal r.args[2], Ruby.int(2)
    assert_equal r.args[3], Ruby.int(3)
    assert_equal r.args[4], Ruby.int(4)
    assert_equal r.args[5].splatted, Ruby.int(5)
    assert_equal r.args[6], Ruby.int(6)
    assert_equal r.args[7], Ruby.int(7)
    assert_equal r.args[8], Ruby.int(8)
    assert_equal r.args[9], Ruby.int(9)
    assert_equal r.args[10], Ruby.int(10)
  end

  def test_five_before_and_after_with_array_as_splat_arg
    r = Ruby.parse('link_to(0,1,2,3,4,*[],6,7,8,9,10)')
    assert_equal 11,r.args.count
    assert_equal r.args[0], Ruby.int(0)
    assert_equal r.args[1], Ruby.int(1)
    assert_equal r.args[2], Ruby.int(2)
    assert_equal r.args[3], Ruby.int(3)
    assert_equal r.args[4], Ruby.int(4)
    assert_equal r.args[5].splatted, Ruby::ArrayLiteral.new
    assert_equal r.args[6], Ruby.int(6)
    assert_equal r.args[7], Ruby.int(7)
    assert_equal r.args[8], Ruby.int(8)
    assert_equal r.args[9], Ruby.int(9)
    assert_equal r.args[10], Ruby.int(10)
  end  

  def test_five_before_and_after_with_array_as_splat_arg_as_some_of_other_args
    r = Ruby.parse('link_to([],1,2,3,4,*[],6,7,8,[],10)')
    assert_equal 11,r.args.count
    assert_equal r.args[0], Ruby::ArrayLiteral.new
    assert_equal r.args[1], Ruby.int(1)
    assert_equal r.args[2], Ruby.int(2)
    assert_equal r.args[3], Ruby.int(3)
    assert_equal r.args[4], Ruby.int(4)
    assert_equal r.args[5].splatted, Ruby::ArrayLiteral.new
    assert_equal r.args[6], Ruby.int(6)
    assert_equal r.args[7], Ruby.int(7)
    assert_equal r.args[8], Ruby.int(8)
    assert_equal r.args[9], Ruby::ArrayLiteral.new
    assert_equal r.args[10], Ruby.int(10)
  end  

  def test_parsing_array_containing_splat_at_end
    r = Ruby.parse("[1, *2]")

    assert_node r, Ruby::ArrayLiteral, values: [Ruby.int(1), Ruby.splat(Ruby.int(2))]
  end

  def test_parsing_array_containing_splat_at_start
    r = Ruby.parse("[*1, 2]")

    assert_node r, Ruby::ArrayLiteral, values: [Ruby.splat(Ruby.int(1)), Ruby.int(2)]
  end

  def test_parsing_array_containing_splat_in_the_middle
    r = Ruby.parse("[1, *2, 3]")

    assert_node r, Ruby::ArrayLiteral, values: [Ruby.int(1), Ruby.splat(Ruby.int(2)), Ruby.int(3)]
  end

  def test_multiple_assignment_in_block_args
    r = Ruby.parse('m() { |params, (key, value)| 1}')

    assert_node r.block_arg, Ruby::CodeBlock
    assert_equal 2, r.block_arg.args.count
    assert_node r.block_arg.args[0], Ruby::Argument, name:'params'
    assert_node r.block_arg.args[1], Ruby::SplittedArgument, names:['key','value']
  end

  def splatted_array
    splatted = Ruby::Splat.new
    splatted.splatted = Ruby::ArrayLiteral.new
    splatted
  end

    def test_args_cat_one
    r = Ruby.parse('m(1,*[])')
    assert_equal [Ruby.int(1),splatted_array], r.args
  end  

  def test_args_cat_two
    r = Ruby.parse('m(1,2,*[])')
    assert_equal [Ruby.int(1),Ruby.int(2),splatted_array], r.args
  end  

  def test_args_push_one
    r = Ruby.parse('m(*[],1)')
    assert_equal [splatted_array,Ruby.int(1)], r.args
   end

  def test_args_push_two
    r = Ruby.parse('m(*[],1,2)')
    assert_equal [splatted_array,Ruby.int(1),Ruby.int(2)], r.args
  end

  def test_args_cat_or_push_zero   
    r = Ruby.parse('m(*[])')
    assert_equal [splatted_array], r.args
  end  

  def test_args_cat_and_push_two
    r = Ruby.parse('m(1,2,*[],3,4)')
    assert_equal [Ruby.int(1),Ruby.int(2),splatted_array,Ruby.int(3),Ruby.int(4)],r.args
  end

end