require 'rgen/metamodel_builder'

module RubyMM

	class Value < RGen::MetamodelBuilder::MMBase
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

	class Def < RGen::MetamodelBuilder::MMBase
		has_attr 'name', String
		has_one 'body', Value
	end

	class Literal < Value
	end

	class IntLiteral < Literal
		has_attr 'value', Integer
	end

	class StringLiteral < Literal
		has_attr 'value', String
	end

	class Const < RGen::MetamodelBuilder::MMBase
		has_attr 'name', String
		has_one 'container',Const
	end

	# class ClassRef < RGen::MetamodelBuilder::MMBase
	# 	has_one 'constant', ConstantAccess

	# 	def self.assign(obj,value)
	# 		if value.is_a? ConstantAccess
	# 			obj.constant = value
	# 		else
	# 			raise "Unknown: #{value} (#{value.class})"
	# 		end
	# 	end
	# end

	class ClassDecl < RGen::MetamodelBuilder::MMBase
		has_one 'super_class',Const
	end

end