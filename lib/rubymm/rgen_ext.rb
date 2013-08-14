require 'rgen/metamodel_builder'

module RGen

	class UnexistingFeature < Exception
		attr_reader :feat_name
		def initialize(feat_name)
			@feat_name = feat_name
		end
		def to_s
			"UnexistingFeature: '#{@feat_name}'"
		end
	end

	class SingleAttributeRequired < Exception
		def initialize(class_name,attributes)
			@class_name = class_name
			@attributes = attributes
		end
		def to_s
			names = []
			@attributes.each {|a| names << a.name}
			"SingleAttributeRequired: '#{@class_name}', attributes: #{names.join(', ')}"
		end
	end

end

class RGen::MetamodelBuilder::MMBase

	module ClassAddOn

		def build(values={})
			instance = self.new
			if values.is_a? Hash
				values.each do |k,v|
					attribute = self.ecore.eAllAttributes.find {|x| x.name==k.to_s}
					reference = self.ecore.eAllReferences.find {|x| x.name==k.to_s}
					raise RGen::UnexistingFeature.new(k.to_s) unless (attribute or reference)
					setter = (k.to_s+'=').to_sym
					instance.send setter, v
				end
			else
				has_dynamic = false
				self.ecore.eAllAttributes.each {|a| has_dynamic|=a.name=='dynamic'}
				d = 0
				d = 1 if has_dynamic

				raise RGen::SingleAttributeRequired.new(self.ecore.name,self.ecore.eAllAttributes) if self.ecore.eAllAttributes.count!=1+d
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

		# It does not check references, it is needed to avoid infinite recursion
		def shallow_eql?(other)
			return false if other==nil
			return false unless self.class==other.class
			self.class.ecore.eAllAttributes.each do |attrib|
				if attrib.name != 'dynamic' # I have to understand this...
					self_value = self.get(attrib)
					other_value = other.get(attrib)
					#puts "returning false on #{attrib.name}" unless self_value.eql?(other_value)
					return false unless self_value == other_value
				end
			end
			true
		end

		def eql?(other)
			# it should ignore relations which has as opposite a containement
			return false unless self.shallow_eql?(other)
			self.class.ecore.eAllReferences.each do |ref|
				self_value = self.get(ref)
				other_value = other.get(ref)
				to_ignore = ref.getEOpposite and ref.getEOpposite.containment
				#puts "ignore #{self.class.name}.#{ref.name}" if to_ignore
				#puts "returning false on #{attrib.name}" unless self_value.eql?(other_value)
				unless to_ignore
					if ref.containment
						return false unless self_value == other_value
					else
						if (self_value.is_a? Array) or (other_value.is_a? Array)
							return false unless self_value.count==other_value.count
							for i in 0..(self_value.count-1)
								return false unless self_value[i].shallow_eql?(other_value[i])
							end
						else  
							if self_value==nil
								return false unless other_value==nil
							else
								return false unless self_value.shallow_eql?(other_value)
							end
						end
					end
				end						
			end
			true
		end

		def ==(other)
			eql? other
		end
	
		def get(attr_or_ref)
			getter = (attr_or_ref.name).to_sym
			send getter
		end

	end

	class << self
		include ClassAddOn
	end

	include SingletonAddOn
end
