curr_dir = File.dirname(__FILE__)
Dir[curr_dir+"/jars/*.jar"].each do |jar|
	require jar
end

require 'rubymm/metamodel'
require 'rubymm/parser'