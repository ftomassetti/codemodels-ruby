require 'helper'

class TestBlocks < Test::Unit::TestCase

	include TestHelper
  include LightModels

	def test_passing_block_do
		root = Ruby.parse("[].select do |x|\nx\nend")
  	#puts "ROOT=#{root.inspect}"
  	assert_node root, Ruby::Call, name: 'select'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, Ruby::CodeBlock,
  	args:[Ruby::Argument.build('x')],
  	body: Ruby::BlockVarAccess.build('x')
  end

  def test_passing_block_cb # cb: curly braces
  	root = Ruby.parse("[].select {|x| x }")
  	assert_node root, Ruby::Call, name: 'select'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, Ruby::CodeBlock,
  	args:[Ruby::Argument.build('x')],
  	body: Ruby::BlockVarAccess.build('x')
  end

  #iter blocks are treated differently from the JRubyParser
  def test_passing_iter_block_do
  	root = Ruby.parse("[].each do |x|\nx\nend")
  	#puts "ROOT=#{root.inspect}"
  	assert_node root, Ruby::Call, name: 'each'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, Ruby::CodeBlock,
  	args:[Ruby::Argument.build('x')],
  	body: Ruby::BlockVarAccess.build('x')
  end

  def test_passing_iter_block_cb # cb: curly braces
  	root = Ruby.parse("[].each {|x| x }")
  	assert_node root, Ruby::Call, name: 'each'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, Ruby::CodeBlock,
  	args:[Ruby::Argument.build('x')],
  	body: Ruby::BlockVarAccess.build('x')
  end

  def test_block_passed_using_symbol
  	root = Ruby.parse('@issues.map(&:new_statuses_allowed_to)')
  	assert_node root, Ruby::Call, name: 'map'
  	assert_equal 0,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, Ruby::BlockReference,
  	value: Ruby::Symbol.build('new_statuses_allowed_to')
  end

  def test_block_passed_using_symbol_and_other_param
  	root = Ruby.parse('@issues.map(1,&:new_statuses_allowed_to)')
  	assert_node root, Ruby::Call, name: 'map'
  	assert_equal 1,root.args.count
  	assert_not_nil root.block_arg
  	assert_node root.block_arg, Ruby::BlockReference,
  		value: Ruby::Symbol.build('new_statuses_allowed_to')
  end

  def test_begin_empty
  	root = Ruby.parse('begin;end')
  	assert_node root, Ruby::BeginEndBlock,
  	body: nil
  	assert_equal 0,root.rescue_clauses.count
  end

  def test_begin_one_value
  	root = Ruby.parse('begin;1;end')
  	assert_node root, Ruby::BeginEndBlock,
  	body: Ruby.int(1)
  	assert_equal 0,root.rescue_clauses.count
  end

  def test_begin_many_values
  	root = Ruby.parse('begin;1;2;end')
  	assert_node root, Ruby::BeginEndBlock, {}
  	assert root.body.is_a? Ruby::Block
  	assert_equal 2,root.body.contents.count
  	assert_is_int root.body.contents[0], 1
  	assert_is_int root.body.contents[1], 2
  end

  def test_forward_block
  	 root = Ruby.parse('def project_tree(projects, &block);Project.project_tree(projects, &block);end')

  	 call_in_def = root.body
  	 assert_equal 'project_tree',call_in_def.name
  	 assert_equal 1, call_in_def.args.count # the block arg does not count!
  	 assert_node call_in_def.block_arg,Ruby::BlockReference,
  	 	value: Ruby::LocalVarAccess.build(name: 'block')
  end

end