curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/jars/*.jar"].each do |jar|
	require jar
end

require 'ruby-lightmodels/metamodel'
require 'ruby-lightmodels/query'
require 'ruby-lightmodels/parser'
require 'ruby-lightmodels/model_building'
require 'ruby-lightmodels/info_extraction'
require 'ruby-lightmodels/code'
require 'ruby-lightmodels/language'