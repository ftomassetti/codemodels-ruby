curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/jars/*.jar"].each do |jar|
	require jar
end

require 'codemodels/ruby/metamodel'
require 'codemodels/ruby/query'
require 'codemodels/ruby/parser'
require 'codemodels/ruby/model_building'
require 'codemodels/ruby/info_extraction'
require 'codemodels/ruby/code'
require 'codemodels/ruby/language'