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

	class StringLiteral < Literal
		has_attr 'value', String
		has_attr 'dynamic', Boolean
		has_many 'pieces', Value # only for dynamic
	end

	def self.string(value)
		node = StringLiteral.new
		node.value = value
		node
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
		end
		include Methods
	end

	def self.constant(first_part,*other_parts)
		#puts "first_part: #{first_part}"
		#puts "other_parts: #{other_parts}"

		cont = Constant.build(first_part)

		return cont if other_parts.count == 0

		new_first_part, *new_other_parts = other_parts
		#new_other_parts = [] if new_other_parts==[[]]

		#puts "new_first_part: #{new_first_part}"
		#puts "new_other_parts: #{new_other_parts}"
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
		has_many 'body',Value
	end

	class Symbol < Value
		has_attr 'name', String
	end

	class LocalVarAssignment < Value
	end

	class LocalVarAccess < Value
	end

end