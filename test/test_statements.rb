require 'helper'

require 'test/unit'
require 'ruby-lightmodels'
 
class TestOperations < Test::Unit::TestCase

	include TestHelper

	def test_alias
		root = RubyMM.parse("alias pippo display")

		assert_node root, RubyMM::AliasStatement,
		new_name: LiteralReference.build('pippo'),
		old_name: LiteralReference.build('display')
	end

	def test_case_single_when
		r = RubyMM.parse("case v; when 'A'; 1;end")

		assert_node r, RubyMM::CaseStatement, else_body: nil
		assert_equal 1, r.when_clauses.count
		assert_node r.when_clauses[0], RubyMM::WhenClause, condition: RubyMM.string('A'), body: RubyMM.int(1)
	end

	def test_case_two_whens
		r = RubyMM.parse("case v; when 'A'; 1; when 'B'; 2; end")

		assert_node r, RubyMM::CaseStatement, else_body: nil
		assert_equal 2, r.when_clauses.count
		assert_node r.when_clauses[0], RubyMM::WhenClause, condition: RubyMM.string('A'), body: RubyMM.int(1)
		assert_node r.when_clauses[1], RubyMM::WhenClause, condition: RubyMM.string('B'), body: RubyMM.int(2)
	end

	def test_case_two_whens_and_else
		r = RubyMM.parse("case v; when 'A'; 1; when 'B'; 2; else; 3; end")

		assert_node r, RubyMM::CaseStatement, else_body: RubyMM.int(3)
		assert_equal 2, r.when_clauses.count
		assert_node r.when_clauses[0], RubyMM::WhenClause, condition: RubyMM.string('A'), body: RubyMM.int(1)
		assert_node r.when_clauses[1], RubyMM::WhenClause, condition: RubyMM.string('B'), body: RubyMM.int(2)		
	end

end