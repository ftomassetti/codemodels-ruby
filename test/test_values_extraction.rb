require 'helper'
require 'test/unit'
require 'ruby-lightmodels'

class TestValuesExtraction < Test::Unit::TestCase

	include LightModels
	include LightModels::Ruby
	include TestHelper

	def setup
		@addCommentsPermissions_model_node = Ruby.parse_code(read_test_data('012_add_comments_permissions.rb'))
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
			LightModels::InfoExtraction.values_map(m))
	end
end