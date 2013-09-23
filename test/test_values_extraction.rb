require 'helper'

class TestValuesExtraction < Test::Unit::TestCase

	include LightModels
	include LightModels::Ruby
	include TestHelper

	def setup
		@addCommentsPermissions_model_node = Ruby.parse_code(read_test_data('012_add_comments_permissions.rb'))
		@issuesHelperTest_model_node = Ruby.parse_code(read_test_data('issues_helper_test.rb'))
	end

	def test_values_extraction_addCommentsPermissions_method_1
		m = @addCommentsPermissions_model_node.contents[1]
		assert_node m,Def,{name: 'up'}
		assert_map_equal(
			{'up'=>1, 'Permission'=>2,'create'=>2,'controller'=>2,'news'=>2,
				'action'=>2,'add_comment'=>1,'destroy_comment'=>1,				
				'description'=>2,'label_comment_add'=>1,'label_comment_delete'=>1,
				'sort'=>2,1130=>1,1133=>1,
				'is_public'=>2,false=>2,'mail_option'=>2,'mail_enabled'=>2,0=>4}, 
			m.values_map)
		@issuesHelperTest_model_node = Ruby.parse_code(read_test_data('issues_helper_test.rb'))
	end

	def test_values_extraction_issuesHelperTest_method_1
		m = @issuesHelperTest_model_node.contents[1].contents[32]
		assert_node m,Def,{name: 'test_show_detail_relation_added_with_inexistant_issue'}
		assert_map_equal(
			{'test_show_detail_relation_added_with_inexistant_issue'=>1,
				'inexistant_issue_number'=>5, 9999=>1,
				'assert_nil'=>1,'Issue'=>1,'find_by_id'=>1,
				'detail'=>3,'JournalDetail'=>1,'new'=>1,
				'property'=>1,'relation'=>1,
				'prop_key'=>1,'label_precedes'=>1,
				'value'=>1,'assert_equal'=>2,
				'Precedes Issue #'=>1,' added'=>1,
				'show_detail'=>2,false=>1,true=>1,
				'<strong>Precedes</strong> <i>Issue #'=>1,
				'</i> added'=>1}, 
			m.values_map)
	end

	def test_values_from_arg_names
		code = %q{
			def mymethod(a=1, b=nil, c={})
			end
		}		
		m = Ruby.parse_code(code)
		assert_node m,Def,{name: 'mymethod'}
		assert_map_equal(
			{'mymethod'=>1,1=>1,'a'=>1,'b'=>1,'c'=>1}, 
			m.values_map)
	end

	def test_option_name_example
		code = %q{
			def option_name
 			   OptionName
  			end
		}
		m = Ruby.parse_code(code)
		assert_node m,Def,{name: 'option_name'}
		assert_map_equal(
			{
				'option_name'=>1,
				'OptionName' =>1
			},m.values_map)
	end			

	def test_comment_sorting_example
		code = %q{
			def comments_sorting; self[:comments_sorting] end
		}
		m = Ruby.parse_code(code)
		#puts "Ser: #{JSON.pretty_generate(LightModels::Serialization.jsonize_obj(m))}"
		assert_node m,Def,{name: 'comments_sorting'}
		assert_map_equal(
			{
				'comments_sorting'=>2,
				'[]'=>1
			},m.values_map)		
	end

	def test_comment_sorting_assign_example
		code = %q{	
		  def comments_sorting=(order); self[:comments_sorting]=order end
		}
		m = Ruby.parse_code(code)
		
		assert_node m,Def,{name: 'comments_sorting='}
		# '[]' is not contained because this is an element assignment
		assert_map_equal(
			{
				'comments_sorting='=>1,
				'comments_sorting' =>1,
				'order' => 2
			},m.values_map)		
	end

end