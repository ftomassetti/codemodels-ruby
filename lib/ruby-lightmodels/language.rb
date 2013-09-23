require 'lightmodels'

module LightModels
module Ruby

class RubyLanguage < Language
	def initialize
		super('Ruby')
		@extensions << 'rb'
		@parser = LightModels::Ruby::Parser.new
	end
end

LightModels.register_language RubyLanguage.new

end
end