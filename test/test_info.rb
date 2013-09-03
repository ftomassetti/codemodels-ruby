require 'helper'

require 'test/unit'
require 'ruby-lightmodels'

class TestInfoExtraction < Test::Unit::TestCase

	include TestHelper

	def test_id_to_words_empty
		assert_equal [''],RubyMM::InfoExtraction.id_to_words('')
  end

  def test_id_to_words_one_word
    assert_equal ['ciao'],RubyMM::InfoExtraction.id_to_words('ciao')
  end

  def test_id_to_words_starting_separator
    assert_equal ['ciao'],RubyMM::InfoExtraction.id_to_words('_ciao')
  end

  def test_id_to_words_ending_separator
    assert_equal ['ciao'],RubyMM::InfoExtraction.id_to_words('ciao_')
  end

  def test_id_to_words_many_words
    assert_equal ['ciao','come','stai'],RubyMM::InfoExtraction.id_to_words('ciao_come_stai')
  end

  def test_id_to_words_qmark
    assert_equal ['ciao','come','stai'],RubyMM::InfoExtraction.id_to_words('ciao_come_stai?')
  end

  def test_id_to_words_bang
    assert_equal ['ciao','come','stai'],RubyMM::InfoExtraction.id_to_words('ciao_come_stai!')
  end  

end