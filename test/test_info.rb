require 'helper'

require 'test/unit'
require 'ruby-lightmodels'

class TestInfoExtraction < Test::Unit::TestCase

	include TestHelper
  include LightModels

	def test_id_to_words_empty
		assert_equal [''],Ruby::InfoExtraction.id_to_words('')
  end

  def test_id_to_words_one_word
    assert_equal ['ciao'],Ruby::InfoExtraction.id_to_words('ciao')
  end

  def test_id_to_words_starting_separator
    assert_equal ['ciao'],Ruby::InfoExtraction.id_to_words('_ciao')
  end

  def test_id_to_words_ending_separator
    assert_equal ['ciao'],Ruby::InfoExtraction.id_to_words('ciao_')
  end

  def test_id_to_words_many_words
    assert_equal ['ciao','come','stai'],Ruby::InfoExtraction.id_to_words('ciao_come_stai')
  end

  def test_id_to_words_qmark
    assert_equal ['ciao','come','stai'],Ruby::InfoExtraction.id_to_words('ciao_come_stai?')
  end

  def test_id_to_words_bang
    assert_equal ['ciao','come','stai'],Ruby::InfoExtraction.id_to_words('ciao_come_stai!')
  end  

  def test_id_to_words_equal
    assert_equal ['ciao','come','stai'],Ruby::InfoExtraction.id_to_words('ciao_come_stai=')
  end  

  def test_assignment_method_name_recognized_as_identifier
    assert Ruby::InfoExtraction.is_id_str'ciao='
  end

  def test_modifier_method_name_recognized_as_identifier
    assert Ruby::InfoExtraction.is_id_str'ciao!'
  end

  def test_boolean_method_name_recognized_as_identifier
    assert Ruby::InfoExtraction.is_id_str'ciao?'
  end

end