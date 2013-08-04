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

end