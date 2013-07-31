require 'rgen/metamodel_builder'

module RubyMM

	class Call < RGen::MetamodelBuilder::MMBase
		has_attr 'name', String
	end

	class Value < RGen::MetamodelBuilder::MMBase
	end

	class Literal < Value
	end

	class IntLiteral < Literal
		has_attr 'value', Integer
	end

	Call.has_many 'args', Value
	Call.has_one 'receiver', Value

end