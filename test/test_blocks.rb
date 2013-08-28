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

  def test_block_passed_using_symbol
  	root = RubyMM.parse('@issues.map(&:new_statuses_allowed_to)')
  	assert_node root, RubyMM::Call, name: 'map'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, RubyMM::BlockReference,
  	name: 'new_statuses_allowed_to'
  end

  def test_block_passed_using_symbol
  	root = RubyMM.parse('@issues.map(1,&:new_statuses_allowed_to)')
  	assert_node root, RubyMM::Call, name: 'map'
  	assert_equal 1,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, RubyMM::BlockReference,
  	name: 'new_statuses_allowed_to'
  end

  def test_begin_empty
  	root = RubyMM.parse('begin;end')
  	assert_node root, RubyMM::BeginEndBlock,
  	body: nil
  	assert_equal 0,root.rescue_clauses.count
  end

  def test_begin_one_value
  	root = RubyMM.parse('begin;1;end')
  	assert_node root, RubyMM::BeginEndBlock,
  	body: RubyMM.int(1)
  	assert_equal 0,root.rescue_clauses.count
  end

  def test_begin_many_values
  	root = RubyMM.parse('begin;1;2;end')
  	assert_node root, RubyMM::BeginEndBlock, {}
  	assert root.body.is_a? RubyMM::Block
  	assert_equal 2,root.body.contents.count
  	assert_is_int root.body.contents[0], 1
  	assert_is_int root.body.contents[1], 2
  end

end