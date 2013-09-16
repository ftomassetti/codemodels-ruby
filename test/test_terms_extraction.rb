require 'helper'
require 'test/unit'
require 'ruby-lightmodels'

class TestTermsExtraction < Test::Unit::TestCase

	include LightModels
	include LightModels::Ruby
	include TestHelper

	def setup
		@addCommentsPermissions_model_node = Ruby.parse_code(read_test_data('012_add_comments_permissions.rb'))
		@userCustomField_model_node = Ruby.parse_code(read_test_data('user_custom_field.rb')) 
		@statusTest_model_node = Ruby.parse_code(read_test_data('status_test.rb')) 
		@issuesHelperTest_model_node = Ruby.parse_code(read_test_data('issues_helper_test.rb'))
	end

	def test_info_extraction_addCommentsPermissions_method_1
		m = @addCommentsPermissions_model_node.contents[1]
		assert_node m,Def,{name: 'up'}
		assert_map_equal(
			{'up'=>1, 'permission'=>2,'create'=>2,'controller'=>2,'news'=>2,
				'action'=>2,'add'=>2,'delete'=>1,'comment'=>4,
				'destroy'=>1,
				'description'=>2,'label'=>2,'sort'=>2,'1130'=>1,'1133'=>1,
				'is_public'=>2,'false'=>2,'option'=>2,'enabled'=>2,'0'=>4,'mail'=>4}, 
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_addCommentsPermissions_method_2
		m = @addCommentsPermissions_model_node.contents[2]
		assert_node m,Def,{name: 'down'}
		assert_map_equal(
			{'down'=>1, 'permission'=>2,'where'=>2,'first'=>2,'destroy'=>3,
				'controller=? and action=?'=>2,'news'=>2,
				'add'=>1,'comment'=>2}, 
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_userCustomField_method_1
		m = @userCustomField_model_node.contents[0]
		assert_node m,Def,{name: 'type_name'}
		assert_map_equal(
			{'type_name'=>1,'label'=>1,'user'=>1,'plural'=>1}, 
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_userCustomField_class
		m = @userCustomField_model_node
		assert_map_equal(
			{'type_name'=>1,'label'=>1,'user'=>2,'plural'=>1,'custom_field'=>2}, 
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_statusTest_method_1
		m = @statusTest_model_node.contents[1].contents[1]
		assert_node m,Def,{name: 'test_state_conditional'}
		#puts "#{LightModels::Serialization.jsonize_obj(m)}"
		assert_map_equal(
			{'test'=>1,'state_conditional'=>1,
			'assert'=>5,'result'=>5,
			'missing'=>4,'successful'=>4,'unsuccessful'=>2,
			'[]'=>5,'!'=>2}, 
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_issuesHelperTest_method_1
		m = @issuesHelperTest_model_node.contents[1].contents[32]
		assert_node m,Def,{name: 'test_show_detail_relation_added_with_inexistant_issue'}
		raise 'WRITE ME'
	end

	def test_info_extraction_issuesHelperTest_method_2
		m = @issuesHelperTest_model_node.contents[1].contents[34]
		assert_node m,Def,{name: 'test_show_detail_relation_deleted'}
		raise 'WRITE ME'
	end

	def test_info_extraction_issuesHelperTest_method_3
		m = @issuesHelperTest_model_node.contents[1].contents[36]
		assert_node m,Def,{name: 'test_show_detail_relation_deleted_should_not_disclose_issue_that_is_not_visible'}
		raise 'WRITE ME'
	end


	 #  def test_show_detail_relation_added_with_inexistant_issue
  #   inexistant_issue_number = 9999
  #   assert_nil  Issue.find_by_id(inexistant_issue_number)
  #   detail = JournalDetail.new(:property => 'relation',
  #                              :prop_key => 'label_precedes',
  #                              :value    => inexistant_issue_number)
  #   assert_equal "Precedes Issue ##{inexistant_issue_number} added", show_detail(detail, true)
  #   assert_equal "<strong>Precedes</strong> <i>Issue ##{inexistant_issue_number}</i> added", show_detail(detail, false)
  # end

end