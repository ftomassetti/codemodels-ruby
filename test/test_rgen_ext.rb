require 'helper'
require 'test/unit'
require 'rubymm'

class FirstClass < RGen::MetamodelBuilder::MMBase
	has_attr 'name', String
	has_attr 'code', Integer
end

class SecondClass < RGen::MetamodelBuilder::MMBase
	has_attr 'single_attr', String
end

class TestOperations < Test::Unit::TestCase

	def test_build_with_wrong_param
		assert_raise RGen::UnexistingAttribute do
			instance = FirstClass.build({'unexisting_attr'=>'some_val'})
		end
	end

	def test_setting_the_first_two_params
		instance = FirstClass.build({'name'=>'a name'})
		assert_equal 'a name',instance.name
	end

	def test_setting_the_second_of_two_params
		instance = FirstClass.build({'code'=>123})
		assert_equal 123,instance.code		
	end

	def test_setting_both_of_two_params
		instance = FirstClass.build({'name'=>'a name','code'=>123})
		assert_equal 'a name',instance.name
		assert_equal 123,instance.code		
	end

	def test_setting_with_single_param
		instance = SecondClass.build 'my value'
		assert_equal 'my value',instance.single_attr
	end

	def test_equal_int_attr_different
		inst1 = FirstClass.build({'name'=>'a name','code'=>123})
		inst2 = FirstClass.build({'name'=>'a name','code'=>124})
		assert_equal false, inst1.eql?(inst2)
	end

	def test_equal_str_attr_different
		inst1 = FirstClass.build({'name'=>'a name','code'=>123})
		inst2 = FirstClass.build({'name'=>'another name','code'=>123})
		assert_equal false, inst1.eql?(inst2)
	end

	def test_both_attrs_equal
		inst1 = FirstClass.build({'name'=>'a name','code'=>123})
		inst2 = FirstClass.build({'name'=>'a name','code'=>123})
		assert_equal true, inst1.eql?(inst2)
	end

end