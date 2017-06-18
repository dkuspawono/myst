require "./visitor"
require "./interpreter/*"

module Myst
  class Interpreter < Visitor
    property stack : StackMachine
    property symbol_table : SymbolTable

    def initialize
      @stack = StackMachine.new
      @symbol_table = SymbolTable.new
      @symbol_table.push_scope(Kernel::SCOPE)
    end

    macro recurse(node)
      {{node}}.accept(self, io)
    end

    visit AST::Node do
      raise "Unsupported node `#{node.class.name}`"
    end



    # Lists

    visit AST::Block do
      node.children.each_with_index do |child, index|
        recurse(child)
        # The last expression in a block is the implicit return value, so
        # it should stay on the stack.
        stack.pop() unless index == node.children.size - 1
      end
    end

    visit AST::ExpressionList do
      node.children.each do |child|
        recurse(child)
      end
    end



    # Statements

    visit AST::FunctionDefinition do
      functor = TFunctor.new(node)
      @symbol_table[node.name] = functor
      stack.push(functor)
    end



    # Assignments

    visit AST::SimpleAssignment do
      recurse(node.value)
      target = node.target

      # If the target is an identifier, recursing is unnecessary.
      if target.is_a?(AST::VariableReference)
        # The return value of an assignment is the value being assigned,
        # so there is no need to pop it from the stack. This also ensures
        # that the value is treated as a reference, rather than a copy.
        @symbol_table[target.name] = stack.last
      end
    end



    # Conditionals

    visit AST::IfExpression, AST::ElifExpression do
      recurse(node.condition.not_nil!)
      if stack.pop().truthy?
        recurse(node.body)
      else
        if node.alternative
          recurse(node.alternative.not_nil!)
        else
          stack.push(TNil.new)
        end
      end
    end

    visit AST::UnlessExpression do
      recurse(node.condition.not_nil!)
      unless stack.pop().truthy?
        recurse(node.body)
      else
        if node.alternative
          recurse(node.alternative.not_nil!)
        else
          stack.push(TNil.new)
        end
      end
    end

    visit AST::ElseExpression do
      recurse(node.body)
    end

    visit AST::WhileExpression do
      recurse(node.condition)
      while stack.pop().truthy?
        recurse(node.body)
        recurse(node.condition)
      end
    end

    visit AST::UntilExpression do
      recurse(node.condition)
      until stack.pop().truthy?
        recurse(node.body)
        recurse(node.condition)
      end
    end


    # Binary Expressions

    visit AST::LogicalExpression do
      case node.operator.type
      when Token::Type::ANDAND
        recurse(node.left)
        return unless stack.last.truthy?
        stack.pop
        # Recursing the right node should leave it's result on the stack
        recurse(node.right)
      when Token::Type::OROR
        recurse(node.left)
        return if stack.last.truthy?
        stack.pop
        # Recursing the right node should leave it's result on the stack
        recurse(node.right)
      end
    end

    visit AST::EqualityExpression, AST::RelationalExpression, AST::BinaryExpression do
      recurse(node.left)
      recurse(node.right)

      b = stack.pop
      a = stack.pop

      stack.push(Calculator.do(node.operator, a, b))
    end



    # Postfix Expressions

    visit AST::FunctionCall do
      case (func = node.function)
      when AST::VariableReference
        functor = @symbol_table[func.name]?
        if functor.is_a?(TFunctor)
          recurse(node.arguments)
          @symbol_table.push_scope(functor.scope.full_clone)
          functor.parameters.children.reverse_each do |param|
            @symbol_table.assign(param.name, stack.pop(), make_new: true)
          end
          recurse(functor.body)
          @symbol_table.pop_scope()
        elsif functor.is_a?(TNativeFunctor)
          recurse(node.arguments)
          args = node.arguments.children.map{ |arg| stack.pop }
          stack.push(functor.call(args))
        end
      else
        raise "Function names must be identifiers."
      end
    end



    # Literals

    visit AST::VariableReference do
      if value = @symbol_table[node.name]?
        stack.push(value)
      else
        raise "Undefined variable `#{node.name}` in current scope."
      end
    end

    visit AST::IntegerLiteral do
      stack.push(TInteger.new(node.value.to_i64))
    end

    visit AST::FloatLiteral do
      stack.push(TFloat.new(node.value.to_f64))
    end

    visit AST::StringLiteral do
      stack.push(TString.new(node.value))
    end

    visit AST::BooleanLiteral do
      stack.push(TBoolean.new(node.value))
    end
  end
end