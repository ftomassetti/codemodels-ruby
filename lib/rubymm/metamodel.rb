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

	class Constant < RGen::MetamodelBuilder::MMBase
		has_attr 'name', String
		has_one 'container',Constant
	end

	class ClassDecl < RGen::MetamodelBuilder::MMBase
		has_one 'defname', Constant
		has_one 'super_class',Constant
		has_many 'body',Value
	end

	class Symbol < Value
		has_attr 'name', String
	end

end