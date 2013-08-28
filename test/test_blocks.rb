require 'helper'

require 'test/unit'
require 'rubymm'
 
class TestBlocks < Test::Unit::TestCase

  include TestHelper

   def test_passing_block_do
  	root = RubyMM.parse("[].select do |x|\nx\nend")
  	#puts "ROOT=#{root.inspect}"
  	assert_node root, RubyMM::Call, name: 'select'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, RubyMM::CodeBlock,
  			args:[RubyMM::Argument.build('x')],
  			body: RubyMM::BlockVarAccess.build('x')
  end

  def test_passing_block_cb # cb: curly braces
  	root = RubyMM.parse("[].select {|x| x }")
  	assert_node root, RubyMM::Call, name: 'select'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, RubyMM::CodeBlock,
  			args:[RubyMM::Argument.build('x')],
  			body: RubyMM::BlockVarAccess.build('x')
  end

  #iter blocks are treated differently from the JRubyParser
  def test_passing_iter_block_do
  	root = RubyMM.parse("[].each do |x|\nx\nend")
  	#puts "ROOT=#{root.inspect}"
  	assert_node root, RubyMM::Call, name: 'each'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, RubyMM::CodeBlock,
  			args:[RubyMM::Argument.build('x')],
  			body: RubyMM::BlockVarAccess.build('x')
  end

  def test_passing_iter_block_cb # cb: curly braces
  	root = RubyMM.parse("[].each {|x| x }")
  	assert_node root, RubyMM::Call, name: 'each'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, RubyMM::CodeBlock,
  			args:[RubyMM::Argument.build('x')],
  			body: RubyMM::BlockVarAccess.build('x')
  end

end