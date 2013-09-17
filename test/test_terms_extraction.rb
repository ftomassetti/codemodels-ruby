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
		@darcsAdapter_model_node = Ruby.parse_code(read_test_data('darcs_adapter.rb'))
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
		assert_map_equal(
			{"9999"=>1,          # 
				"inexistant"=>6, #
				"issue"=>7,      #
				"number"=>5,     #
				"find"=>1, #
				"by"=>1, #
				"id"=>1, #
				"assert"=>3, #
				 "nil"=>1,  #
				 "property"=>1, #
				"relation"=>2, #
				"prop_key"=>1, #
				"label_precedes"=>1, #
				"value"=>1, #
				"journal"=>1, #
				"detail"=>7, #
				"new"=>1, #
				"Precedes Issue #"=>1, #
				"added"=>2, #
				 "true"=>1, #
				 "show"=>3, #
				"equal"=>2, #
				"<strong>Precedes</strong> <i>Issue #"=>1, #
				"</i> added"=>1, #
				"false"=>1, #
				"test"=>1, #
				"with"=>1}, #
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_issuesHelperTest_method_2
		m = @issuesHelperTest_model_node.contents[1].contents[34]
		assert_node m,Def,{name: 'test_show_detail_relation_deleted'}
		assert_map_equal(
			{
				"assert"=>2, #
				 "match"=>1,  #
				 "property"=>1, #
				"relation"=>2, #
				"prop_key"=>1, #
				"label_precedes"=>1, #
				"1"=>1, #
				'old'=>1,#
				"value"=>1, #
				"journal"=>1, #
				"detail"=>7, #
				"new"=>1, #
				"Precedes deleted (Bug #1: Can't print recipes)"=>1, #
				"deleted"=>1, #
				 "true"=>1, #
				 "show"=>3, #
				"equal"=>1, #
				%q{<strong>Precedes</strong> deleted \(<i><a href="/issues/1" class=".+">Bug #1</a>: Can&#x27;t print recipes</i>\)}=>1, #
				"false"=>1, #
				"test"=>1 }, 
			InfoExtraction.terms_map(m))
	end

	def test_info_extraction_darcsAdapter_method_1
		m = @darcsAdapter_model_node.contents[2].contents[0].contents[0].contents[0].contents[4]
		assert_node m,Def,{name: 'info'}
		assert_map_equal(
			{
				'info'=>2,
				'rev'=>3,
				'revisions'=>1,
				'limit'=>1,
				'1'=>1,
				'new'=>1,
				'root'=>1,
				'url'=>2,
				'lastrev'=>1,
				'last'=>1
			},InfoExtraction.terms_map(m))
	end

	def test_info_extraction_darcsAdapter_method_2
		m = @darcsAdapter_model_node.contents[2].contents[0].contents[0].contents[0].contents[5]
		assert_node m,Def,{name: 'entries'}
		assert_map_equal(
			{
				'entries'=>7,
				'new'=>2,
				'identifier'=>3,
				'options'=>1,
				'path'=>9,
				'prefix'=>3,
				'' => 2,
				'/'=> 1,
				'blank'=>2,
				'class'=>2,
				'client_version'=>1,
				'above'=>1,
				'2'=>2,
				'0'=>2,
				'url'=>2,
				'.'=>1,
				'cmd'=>4,
				'sq_bin'=>1,
				'annotate --repodir'=>1,
				'shell_quote'=>3,
				'--xml-output'=>1,
				'--match'=>1,
				'hash'=>1,
				'shellout'=>1,
				'io'=>2,
				'doc'=>5,
				'root'=>3,
				'name'=>4,
				'directory'=>2,
				'element'=>3,
				'elements'=>1,
				'each'=>1,
				'file'=>2,
				'include'=>1,
				'directory/*'=>1,
				'rexml'=>1,
				'document'=>1,
				'entry'=>2,
				'from'=>2,
				'xml'=>2,
				'?'=>2,
				'exitstatus'=>1,
				'compact'=>1,
				'sort_by'=>1,
				'<<'=>4,
				'=='=>2,
				'!='=>1
			},InfoExtraction.terms_map(m))
	end	

	# def test_info_extraction_query
	# 	c = @query_model_node.contents[3]
	# 	assert_equal 'Query',c.defname.name
	# 	m = c.contents[76]
	# 	assert_equal 'sql_for_field',m.name
	# 	puts "=== VALUES MAP ==="
	# 	puts LightModels::InfoExtraction.values_map(m)
	# 	puts "=== TERMS MAP ==="
	# 	#putsInfoExtraction.terms_map(m)
	# 	puts InfoExtraction.terms_map(m)
	# 	#puts "CLASS NAME #{m.defname.name}"
	# 	#assert_node m,Def,{name: 'up'}

	# end

end