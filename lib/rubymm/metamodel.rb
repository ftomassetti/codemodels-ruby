require 'rgen/metamodel_builder'
require 'rubymm/rgen_ext'

module RubyMM

	class Value < RGen::MetamodelBuilder::MMBase
	end

	class Statement < Value
	end

	class IfStatement < Statement
		contains_one_uni 'condition', Value
		contains_many_uni 'body', Value
	end

	class Block < Value
		contains_many_uni 'contents', Value
	end 

	class Call < Value
		has_attr 'name', String
		contains_many_uni 'args', Value
		contains_one_uni 'receiver', Value
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
		contains_one_uni 'body', Value
		has_attr 'onself',Boolean
	end

	class Literal < Value
		module Methods

			def to_s
				value.to_s
			end

			def inspect
				"#{self.class}[#{to_s}]"
			end

		end

		include Methods
	end

	class BooleanLiteral < Literal
		has_attr 'value', Boolean
	end

	class IntLiteral < Literal
		has_attr 'value', Integer
	end

	def self.bool(value)
		BooleanLiteral.build(value)
	end

	def self.int(value)
		IntLiteral.build(value)
	end

	class StringLiteral < Literal
		has_attr 'value', String
		has_attr 'dynamic', Boolean
		contains_many_uni 'pieces', Value # only for dynamic strings
	end

	def self.string(value)
		StringLiteral.build(value)
	end

	class NilLiteral < Literal
	end

	class Constant < Value
		has_attr 'name', String
		contains_one_uni 'container',Constant
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

	class ModuleDecl < Value
		contains_one_uni 'defname', Constant
		contains_many_uni 'contents', Value
	end

	class ClassDecl < Value
		contains_one_uni 'defname', Constant
		contains_one_uni 'super_class',Constant
		contains_many_uni 'contents', Value
	end

	class Symbol < Value
		has_attr 'name', String
	end

	class VarAssignement < Value
		has_attr 'name_assigned', String
		contains_one_uni 'value', Value
	end

	class LocalVarAssignment < VarAssignement
	end

	class GlobalVarAssignment < VarAssignement
	end

	class InstanceVarAssignement < VarAssignement
	end

	class VarAccess < Value
		has_attr 'name', String

		module Methods
			def to_s
				name
			end

			def inspect
				"#{self.class}{#{self.to_s}}"
			end
		end
		include Methods
	end

	class LocalVarAccess < VarAccess
	end

	def self.localvarac(name)
		lva = LocalVarAccess.new
		lva.name = name
		lva
	end

	class GlobalVarAccess < VarAccess
	end

	class InstanceVarAccess < VarAccess
	end

	class HashPair < RGen::MetamodelBuilder::MMBase
		contains_one_uni 'key', Value
		contains_one_uni 'value', Value
	end

	class HashLiteral < Literal
		contains_many_uni 'pairs', HashPair
	end

	class ArrayLiteral < Literal
		contains_many_uni 'values', Value
	end

	class BeginRescue < Value
		contains_one_uni 'body',Value
		contains_one_uni 'rescue_body',Value
	end

	class ElementAssignement < Value
		contains_one_uni 'array',Value
		contains_one_uni 'element',Value
		contains_one_uni 'value',Value
	end

	class Return < Statement
		contains_one_uni 'value',Value
	end

end