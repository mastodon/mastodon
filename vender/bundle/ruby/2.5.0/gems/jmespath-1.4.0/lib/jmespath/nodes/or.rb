module JMESPath
  # @api private
  module Nodes
    class Or < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        result = @left.visit(value)
        if JMESPath::Util.falsey?(result)
          @right.visit(value)
        else
          result
        end
      end

      def optimize
        self.class.new(@left.optimize, @right.optimize)
      end
    end
  end
end
