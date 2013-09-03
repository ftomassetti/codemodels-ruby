curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/jars/*.jar"].each do |jar|
	require jar
end

require 'rubylm/metamodel'
require 'rubylm/query'
require 'rubylm/parser'
require 'rubylm/model_building'
require 'rubylm/info_extraction'