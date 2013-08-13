require 'rgen/metamodel_builder'
require 'rubymm/rgen_ext'

module RubyMM

	class Value < RGen::MetamodelBuilder::MMBase
	end

	class Statement < Value
	end

	class IfStatement < Statement
		has_one 'condition', Value
		has_many 'body', Value
	end

	class Block < Value
		has_many 'contents', Value
	end 

	class Call < Value
		has_attr 'name', String
		has_many 'args', Value
		has_one 'receiver', Value
		has_attr 'implicit_receiver', Boolean

		module Methods
			def inspect
				"Call{name=#{name},args=#{args},receiver=#{receiver.class},implicit_receiver=#{implicit_receiver}}"
			end
		end

		include Methods
	end

	class Def < Value
		has_attr 'name', String
		has_one 'body', Value
	end

	class Literal < Value
	end

	class BooleanLiteral < Literal
		has_attr 'value', Boolean
	end

	class IntLiteral < Literal
		has_attr 'value', Integer
	end

	def self.int(value)
		IntLiteral.build(value)
	end

	class StringLiteral < Literal
		has_attr 'value', String
		has_attr 'dynamic', Boolean
		has_many 'pieces', Value # only for dynamic
	end

	def self.string(value)
		StringLiteral.build(value)
	end

	class NilLiteral < Literal
	end

	class Constant < Value
		has_attr 'name', String
		has_one 'container',Constant
		has_one 'top_container',Constant, :derived => true

		module Methods
			def top_container_derived
				return nil unless container
				return container if not container.container
				container.top_container
			end

			def to_s
				return "#{name}" unless container
				"#{container}::#{name}"
			end

			def inspect
				'Constant{'+self.to_s+'}'
			end
		end
		include Methods
	end

	def self.constant(first_part,*other_parts)
		cont = Constant.build(first_part)

		return cont if other_parts.count == 0

		new_first_part, *new_other_parts = other_parts

		internal_constant = constant(new_first_part, *new_other_parts)
		if internal_constant.container
			internal_constant.top_container.container = cont
		else
			internal_constant.container = cont
		end

		internal_constant
	end

	class ClassDecl < Value
		has_one 'defname', Constant
		has_one 'super_class',Constant
		has_many 'contents',Value
	end

	class Symbol < Value
		has_attr 'name', String
	end

	class LocalVarAssignment < Value
		has_attr 'name_assigned', String
		has_one 'value', Value
	end

	class LocalVarAccess < Value
		has_attr 'name', String

		module Methods
			def to_s
				name
			end

			def inspect
				'LocalVarAccess{'+self.to_s+'}'
			end
		end
		include Methods
	end

	def self.localvarac(name)
		lva = LocalVarAccess.new
		lva.name = name
		lva
	end

	class GlobalVarAssignment < Value
		has_attr 'name_assigned', String
		has_one 'value', Value
	end

	class GlobalVarAccess < Value
		has_attr 'name', String

		module Methods
			def to_s
				name
			end

			def inspect
				'GlobalVarAccess{'+self.to_s+'}'
			end
		end
		include Methods
	end

	class HashPair < RGen::MetamodelBuilder::MMBase
		has_one 'key', Value
		has_one 'value', Value
	end

	class HashLiteral < Literal
		has_many 'pairs', HashPair
	end

	class ArrayLiteral < Literal
		has_many 'values', Value
	end

end