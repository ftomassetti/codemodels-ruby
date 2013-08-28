require 'lightmodels'

module RubyMM

def self.generate_ruby_models_in_dir(src,dest,model_ext='rb.lm',max_nesting=500)
	LightModels::ModelBuilding.generate_models_in_dir(src,dest,'rb',model_ext,max_nesting) do |src|
		root = RubyMM.parse_file(src)
		LightModels::Serialization.rgenobject_to_model(root)
	end
end

def self.generate_ruby_model_per_file(src,dest,model_ext='rb.lm',max_nesting=500)
	LightModels::ModelBuilding.generate_model_per_file(src,dest) do |src|
		root = RubyMM.parse_file(src)
		LightModels::Serialization.rgenobject_to_model(root)
	end
end

end