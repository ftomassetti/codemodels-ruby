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

end