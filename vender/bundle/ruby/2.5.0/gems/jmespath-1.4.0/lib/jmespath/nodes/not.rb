module JMESPath
  module Nodes
    class Not < Node

      def initialize(expression)
        @expression = expression
      end

      def visit(value)
        JMESPath::Util.falsey?(@expression.visit(value))
      end

      def optimize
        self.class.new(@expression.optimize)
      end

    end
  end
end
