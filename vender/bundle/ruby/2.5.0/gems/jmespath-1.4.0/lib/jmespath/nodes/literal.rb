module JMESPath
  # @api private
  module Nodes
    class Literal < Node
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def visit(value)
        @value
      end
    end
  end
end
