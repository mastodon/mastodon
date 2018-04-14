module JMESPath
  # @api private
  module Nodes
    class MultiSelectList < Node
      def initialize(children)
        @children = children
      end

      def visit(value)
        if value.nil?
          value
        else
          @children.map { |n| n.visit(value) }
        end
      end

      def optimize
        self.class.new(@children.map(&:optimize))
      end
    end
  end
end
