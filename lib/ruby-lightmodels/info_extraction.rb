require 'java-lightmodels'

module LightModels

module Ruby

module InfoExtraction

def self.is_id_str(s)
	(not s.index /[^A-Za-z0-9_!?=]/) && (s.index /[A-Za-z]/)
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
		words = words + id.split(/[_!?=]/)
		words = words + words_after
		words		
	else
		id.split /[_!?=]/
	end    
end

class RubySpecificInfoExtractionLogic
	
	def terms_containing_value?(value)
		res = ::LightModels::Java::InfoExtraction.is_camel_case_str(value) || LightModels::Ruby::InfoExtraction.is_id_str(value)
		#puts "Contains terms? '#{value}' : #{res} #{::LightModels::Java::InfoExtraction.is_camel_case_str(value)} #{LightModels::Ruby::InfoExtraction.is_id_str(value)}"
		res
	end

	def to_words(value)
		if ::LightModels::Java::InfoExtraction.is_camel_case_str(value)
			res = ::LightModels::Java::InfoExtraction.camel_to_words(value)
			res.each {|v| raise "Camel case to words produced a nil" if v==nil}
			raise "No words found using the camel case to words" if res.count==0
		else
			res = LightModels::Ruby::InfoExtraction.id_to_words(value)
			res.each {|v| raise "Id to words produced a nil" if v==nil}
			raise "No words found using the id to words on '#{value}'" if res.count==0
		end		
		res
	end

	def concat(a,b)
		# if both the words are capitalized then do not insert the 
		# underscore
		#if (a.capitalize==a) && (b.capitalize==b)
		#	return a+b
		#end

		# I use the underscore also for MyIdentifier so that I match
		# my_identifier

		a+'_'+b
	end
end

def self.terms_map(model_node,context=nil)
	LightModels::InfoExtraction.terms_map(RubySpecificInfoExtractionLogic.new,model_node,context)
end

end

end

end
