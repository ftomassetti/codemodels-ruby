require 'helper'
 
class TestOperations < Test::Unit::TestCase

	include TestHelper
	include CodeModels

	def test_alias
		root = Ruby.parse("alias pippo display")

		assert_node root, Ruby::AliasStatement,
		new_name: LiteralReference.build('pippo'),
		old_name: LiteralReference.build('display')
	end

	def test_case_single_when
		r = Ruby.parse("case v; when 'A'; 1;end")

		assert_node r, Ruby::CaseStatement, else_body: nil
		assert_equal 1, r.when_clauses.count
		assert_node r.when_clauses[0], Ruby::WhenClause, condition: Ruby.string('A'), body: Ruby.int(1)
	end

	def test_case_two_whens
		r = Ruby.parse("case v; when 'A'; 1; when 'B'; 2; end")

		assert_node r, Ruby::CaseStatement, else_body: nil
		assert_equal 2, r.when_clauses.count
		assert_node r.when_clauses[0], Ruby::WhenClause, condition: Ruby.string('A'), body: Ruby.int(1)
		assert_node r.when_clauses[1], Ruby::WhenClause, condition: Ruby.string('B'), body: Ruby.int(2)
	end

	def test_case_two_whens_and_else
		r = Ruby.parse("case v; when 'A'; 1; when 'B'; 2; else; 3; end")

		assert_node r, Ruby::CaseStatement, else_body: Ruby.int(3)
		assert_equal 2, r.when_clauses.count
		assert_node r.when_clauses[0], Ruby::WhenClause, condition: Ruby.string('A'), body: Ruby.int(1)
		assert_node r.when_clauses[1], Ruby::WhenClause, condition: Ruby.string('B'), body: Ruby.int(2)		
	end

	def test_while_pre
		r = Ruby.parse('while 1; 2; end')

		assert_node r, Ruby::WhileStatement, condition: Ruby.int(1), body: Ruby.int(2)#, type: :prefixed
	end

	def test_while_post
		r = Ruby.parse('2 while 1')

		assert_node r, Ruby::WhileStatement, condition: Ruby.int(1), body: Ruby.int(2)#, type: :postfixed
	end

	def test_until_pre
		r = Ruby.parse('until 1; 2; end')

		assert_node r, Ruby::UntilStatement, condition: Ruby.int(1), body: Ruby.int(2)#, type: :prefixed
	end

	def test_until_post
		r = Ruby.parse('2 until 1')

		assert_node r, Ruby::UntilStatement, condition: Ruby.int(1), body: Ruby.int(2)#, type: :postfixed
	end	

	def test_if_pre
		r = Ruby.parse('if 1; 2; end')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body: Ruby.int(2), else_body: nil
	end

	def test_if_pre_with_else
		r = Ruby.parse('if 1; 2; else; 3; end')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body: Ruby.int(2), else_body: Ruby.int(3)
	end

	def test_if_post
		r = Ruby.parse('2 if 1')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body: Ruby.int(2), else_body: nil
	end

	def test_termary_operator
		r = Ruby.parse('1 ? 2 : 3')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body: Ruby.int(2), else_body: Ruby.int(3)
	end

	def test_unless_pre
		r = Ruby.parse('unless 1; 2; end')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body:nil, else_body: Ruby.int(2)
	end

	def test_unless_pre_with_else
		r = Ruby.parse('unless 1; 2; else; 3; end')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body: Ruby.int(3), else_body: Ruby.int(2)
	end

	def test_unless_post
		r = Ruby.parse('2 unless 1')

		assert_node r, Ruby::IfStatement, condition: Ruby.int(1), then_body:nil, else_body: Ruby.int(2)
	end

	def test_undef
		r = Ruby.parse('undef pippo')

		assert_node r, Ruby::UndefStatement, name: Ruby::LiteralReference.build('pippo')
	end

	def test_inline_rescue
		r = Ruby.parse('1 rescue 2')

		assert_node r, Ruby::RescueStatement, body: Ruby.int(1), value: Ruby::int(2)
	end

	def test_break
		r = Ruby.parse('break')

		assert_node r, Ruby::BreakStatement
	end

	def test_defined
		r = Ruby.parse('defined? mymethod')

		assert_node r, Ruby::IsDefined
		assert_node r.value, Ruby::Call, name: 'mymethod'
	end

	def test_call_no_receiver_no_params
		r = Ruby.parse('using_open_id?')

		assert_node r, Ruby::Call, name:'using_open_id?', args:[]
	end

	def test_call_only_iter
		r = Ruby.parse('respond_to do |format| 1; end') 

		assert_node r, Ruby::Call, name:'respond_to', args:[]
		assert_node r.block_arg, Ruby::CodeBlock
	end

	def test_call_iter_and_args
		r = Ruby.parse('respond_to(1,2) do |format| 1; end') 

		assert_node r, Ruby::Call, name:'respond_to', args:[Ruby.int(1),Ruby.int(2)]
		assert_node r.block_arg, Ruby::CodeBlock
	end

	def test_call_splat_and_block
		r = Ruby.parse('form_for(*args, &proc)')

		assert_node r, Ruby::Call, name:'form_for'
		assert_equal 1, r.args.count
		assert_node r.args[0], Ruby::Splat
		assert_node r.args[0].splatted, Ruby::Call, name: 'args'
		assert_node r.block_arg, Ruby::BlockReference
		assert_node r.block_arg.value, Ruby::Call, name: 'proc'
	end

	def test_for
		r = Ruby.parse 'for a in 2; 3; end'
		assert_node r, Ruby::ForStatement, collection: Ruby.int(2), iterator: Ruby::LocalVarAssignment.build('a'), body: Ruby.int(3)
	end		

end