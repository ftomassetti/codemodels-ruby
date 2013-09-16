module LightModels

module Ruby

module InfoExtraction

def self.is_id_str(s)
	not s.index /[^A-Za-z0-9_!?]/
end

def self.id_to_words(id)
	return [''] if id==''
	while id.start_with?'_' # otherwise _ciao => ['','ciao']
		id = id[1..-1]
	end

	number_index = id.index /[0-9]/
	if number_index
		if number_index==0
			words_before = []
		else
			id_before = id[0..number_index-1]
			words_before = id_to_words(id_before)
		end

		id_from = id[number_index..-1]
		has_other_after = id_from.index /[^0-9]/
		if has_other_after
			number_word = id_from[0..has_other_after-1]
			id_after = id_from[has_other_after..-1]
			words_after = id_to_words(id_after)
		else
			number_word = id_from
			words_after = []
		end
		words = words_before
		words = words + id.split(/[_!?]/)
		words = words + words_after
		words		
	else
		id.split /[_!?]/
	end    
end

class RubySpecificInfoExtractionLogic
	
	def terms_containing_value?(value)
		LightModels::Ruby::InfoExtraction.is_id_str(value)
	end

	def to_words(value)
		LightModels::Ruby::InfoExtraction.id_to_words(value)
	end

end

def self.terms_map(model_node,context=nil)
	LightModels::InfoExtraction.terms_map(RubySpecificInfoExtractionLogic.new,model_node,context)
end

end

end

end
