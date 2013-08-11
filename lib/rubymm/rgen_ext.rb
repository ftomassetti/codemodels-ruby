require 'rgen/metamodel_builder'

module RGen

	class UnexistingAttribute < Exception
		attr_reader :attr_name
		def initialize(attr_name)
			@attr_name = attr_name
		end
	end

	class SingleAttributeRequired < Exception
	end

end

class RGen::MetamodelBuilder::MMBase

	module ClassAddOn

		def build(values={})
			instance = self.new
			if values.is_a? Hash
				values.each do |k,v|
					attribute = self.ecore.eAllAttributes.find {|x| x.name==k}
					raise RGen::UnexistingAttribute.new(k) unless attribute
					setter = (k+'=').to_sym
					instance.send setter, v
				end
			else
				raise SingleAttributeRequired.new if self.ecore.eAllAttributes.count!=1
				attribute = self.ecore.eAllAttributes[0]
				set_attr(instance,attribute,values)
			end
			instance
		end

		private

		def set_attr(instance,attribute,value)
			setter = (attribute.name+'=').to_sym
			instance.send setter, value
		end
	end

	module SingletonAddOn

		def eql?(other)
			return false unless self.class==other.class
			self.class.ecore.eAllAttributes.each do |attrib|
				if attrib.name != 'dynamic' # I have to understand this...
					self_value = self.get_attr(attrib)
					other_value = other.get_attr(attrib)
					#puts "returning false on #{attrib.name}" unless self_value.eql?(other_value)
					return false unless self_value.eql?(other_value)
				end
			end
			true
		end
	
		def get_attr(attribute)
			getter = (attribute.name).to_sym
			send getter
		end
	end

	class << self
		include ClassAddOn
	end

	include SingletonAddOn
end
