require 'codemodels'

module CodeModels
module Ruby

class RubyLanguage < Language
	def initialize
		super('Ruby')
		@extensions << 'rb'
		@parser = CodeModels::Ruby::Parser.new
	end
end

CodeModels.register_language RubyLanguage.new

end
end