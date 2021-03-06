require 'codemodels'

module CodeModels

module Ruby

	class RubyNode < CodeModelsAstNode
	end

	class Value < RubyNode
	end

	# later attrs like optional or default value could be added
	class Argument < RubyNode
		has_attr 'name', String
	end

	class SplittedArgument < Argument
		has_many_attr 'names', String
	end

	class Statement < Value
	end

	class RegexMatcher < Value
		contains_one_uni 'checked_value', Value
		contains_one_uni 'regex', Value
	end

	class RegexTryer < Value
		contains_one_uni 'checked_value', Value
		contains_one_uni 'regex', Value
	end

	class Range < Value
		contains_one_uni 'lower', Value
		contains_one_uni 'upper', Value
	end

	class IfStatement < Statement
		contains_one_uni 'condition', Value
		contains_one_uni 'then_body', Value
		contains_one_uni 'else_body', Value
	end

	class IsDefined < Value
		contains_one_uni 'value', Value
	end

	class RetryStatement < Statement
	end

	class Block < Value
		contains_many_uni 'contents', Value
	end 

	class AbstractCodeBlock < Value
	end

	class CodeBlock < AbstractCodeBlock
		contains_one_uni 'body', Value
		contains_many_uni 'args', Argument
	end

	class BlockReference < AbstractCodeBlock
		contains_one_uni 'value', Value
	end

	class SuperCall < Statement
		contains_many_uni 'args', Value
		contains_one_uni 'block_arg', AbstractCodeBlock
	end

	class Call < Value
		has_attr 'name', String
		contains_many_uni 'args', Value
		contains_one_uni 'block_arg', AbstractCodeBlock
		contains_one_uni 'receiver', Value

		module Methods
			def inspect
				"Call{name=#{name},args=#{args},receiver=#{receiver.class},implicit_receiver=#{implicit_receiver}}"
			end
		end

		include Methods
	end

	class ExplicitReceiverCall < Call
	end

	class ImplicitReceiverCall < Call
	end

	class CallToSuper < Value
		contains_many_uni 'args', Value
		contains_one_uni 'block_arg', AbstractCodeBlock
	end

	class RescueClause < RubyNode 
		contains_one_uni 'body',Value
	end

	class FormalArgument < RubyNode
		has_attr 'name',String
		contains_one_uni 'default_value',Value
	end

	class Def < Value
		has_attr 'name', String
		contains_one_uni 'body', Value
		contains_one_uni 'ensure_body', Value
		contains_many_uni 'rescue_clauses',RescueClause
		contains_many_uni 'formal_args', FormalArgument
	end

	class SelfDef < Def
	end

	class InstanceDef < Def
	end

	class Literal < Value
		module Methods

			def to_s
				if respond_to? :value
					value.to_s
				else
					super
				end
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

	class FloatLiteral < Literal
		has_attr 'value', Float
	end

	class RegExpLiteral < Literal					
	end

	class StaticRegExpLiteral < RegExpLiteral
		has_attr 'value', String
	end

	class DynamicRegExpLiteral < RegExpLiteral
		contains_many_uni 'pieces', Value # only for dynamic strings
	end

	class NextStatement < Statement
	end

	def self.bool(value)
		BooleanLiteral.build(value)
	end

	def self.int(value)
		IntLiteral.build(value)
	end

	class StringLiteral < Literal		
	end

	class DynamicStringLiteral < StringLiteral
		contains_many_uni 'pieces', Value # only for dynamic strings
	end

	class StaticStringLiteral < StringLiteral
		has_attr 'value', String
	end

	class CmdLineStringLiteral < Literal
		has_attr 'value', String
		contains_many_uni 'pieces', Value # only for dynamic strings		
	end

	class DynamicSymbol < Literal
		#has_attr 'value', String
		contains_many_uni 'pieces', Value	
	end

	def self.string(value)
		StaticStringLiteral.build(value)
	end

	class ConstantDecl < Value
		has_attr 'name', String
		contains_one_uni 'value', Value
	end

	class NilLiteral < Literal
	end

	class Self < Value
	end

	class GlobalScopeReference < Value
		has_attr 'name', String
	end

	# for example the name of a method in an alias statement
	class LiteralReference < Value
		has_attr 'value', String
	end

	class Constant < Value
		has_attr 'name', String
		contains_one_uni 'container',Value
		has_one 'top_container',Value, :derived => true

		module Methods
			def top_container_derived
				return nil unless container
				return container unless (container.respond_to?(:container) and container.container)
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
		contains_one_uni 'super_class',Value
		contains_many_uni 'contents', Value
	end

	class SingletonClassDecl < Value
		contains_one_uni 'object', Value
		contains_many_uni 'contents', Value
	end	

	class Symbol < Literal
		has_attr 'name', String		
	end

	class Assignment < Value
		contains_one_uni 'value', Value
	end

	class VarAssignment < Assignment
		has_attr 'name_assigned', String		
	end

	class LocalVarAssignment < VarAssignment
	end

	class GlobalVarAssignment < VarAssignment
	end

	class InstanceVarAssignment < VarAssignment
	end

	class ClassVarAssignment < VarAssignment
	end

	class BlockVarAssignment < VarAssignment
	end

	class OperatorAssignment < Value
		contains_one_uni 'container', Value
		has_attr 'element_name', String
		contains_one_uni 'value', Value
		has_attr 'operator_name', String
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

	class BlockVarAccess < VarAccess
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

	class ClassVarAccess < VarAccess
	end

	class HashPair < RubyNode
		contains_one_uni 'key', Value
		contains_one_uni 'value', Value
	end

	class HashLiteral < Literal
		contains_many_uni 'pairs', HashPair
	end

	class ArrayLiteral < Literal
		contains_many_uni 'values', Value
	end

	class AliasStatement < Statement
		contains_one_uni 'old_name',Value
		contains_one_uni 'new_name',Value
	end

	class UndefStatement < Statement
		contains_one_uni 'name', Value
	end

	class WhenClause < RubyNode
		contains_one_uni 'condition',Value
		contains_one_uni 'body',Value
	end

	class CaseStatement < Statement
		contains_many_uni 'when_clauses', WhenClause
		contains_one_uni 'else_body', Value
	end

	class WhileStatement < Statement
		contains_one_uni 'condition', Value
		contains_one_uni 'body', Value
		#has_attr 'type', Symbol
	end

	class ForStatement < Statement
		contains_one_uni 'collection', Value
		contains_one_uni 'iterator', Value
		contains_one_uni 'body', Value
	end

	class UntilStatement < Statement
		contains_one_uni 'condition', Value
		contains_one_uni 'body', Value
		#has_attr 'type', Symbol
	end

	class BreakStatement < Statement
	end

	class RescueStatement < Statement
		contains_one_uni 'body', Value
		contains_one_uni 'value', Value
	end

	class BackReference < Value
	end

	class NthGroupReference < Value
		has_attr 'n', Integer
	end

	class YieldStatement < Statement
	end

	class BeginEndBlock < Value
		contains_one_uni 'body',Value
		contains_many_uni 'rescue_clauses',RescueClause
		contains_one_uni 'ensure_body', Value
	end

	class UnaryOperation < Value
		contains_one_uni 'value',Value
		has_attr 'operator_name', String
	end

	class Splat < Value
		contains_one_uni 'splatted', Value
	end

	def self.splat(v)
		s = Splat.new
		s.splatted = v
		s
	end

	# ex a[1] = 2
	class ElementAssignment < Assignment
		contains_one_uni 'container',Value
		contains_one_uni 'element',Value
	end

	# ex a[1] += 2
	class ElementOperationAssignment < Value
		contains_one_uni 'container',Value
		contains_one_uni 'element',Value
		contains_one_uni 'value',Value
		has_attr 'operator',String
	end

	class MultipleAssignment < Value
		contains_many_uni 'assignments',Assignment
		contains_many_uni 'values',Value
	end

	class Return < Statement
		contains_one_uni 'value',Value
	end

	class BinaryOperator < Value
		contains_one_uni 'left',Value
		contains_one_uni 'right',Value		
	end

	class AndOperator < BinaryOperator
		#has_attr 'word_form', Boolean # true for 'and', false for '&&'
	end

	class OrOperator < BinaryOperator
		#has_attr 'word_form', Boolean # true for 'or', false for '||'
	end

	class OrAssignment < Value # ||=
		contains_one_uni 'assigned',Value
		contains_one_uni 'value', Value
	end

end

end