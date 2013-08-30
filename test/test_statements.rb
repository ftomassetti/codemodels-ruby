require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestOperations < Test::Unit::TestCase

  include TestHelper

  def test_alias
  	root = RubyMM.parse("alias pippo display")

  	assert_node root, RubyMM::AliasStatement,
        new_name: LiteralReference.build('pippo'),
        old_name: LiteralReference.build('display')
  end

  

end