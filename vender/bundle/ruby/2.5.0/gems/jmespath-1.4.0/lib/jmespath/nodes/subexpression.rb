module JMESPath
  # @api private
  module Nodes
    class Subexpression < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        @right.visit(@left.visit(value))
      end

      def optimize
        Chain.new(flatten).optimize
      end

      protected

      attr_reader :left, :right

      def flatten
        nodes = [@left, @right]
        until nodes.none? { |node| node.is_a?(Subexpression) }
          nodes = nodes.flat_map do |node|
            if node.is_a?(Subexpression)
              [node.left, node.right]
            else
              [node]
            end
          end
        end
        nodes.map(&:optimize)
      end
    end

    class Chain
      def initialize(children)
        @children = children
      end

      def visit(value)
        @children.reduce(value) do |v, child|
          child.visit(v)
        end
      end

      def optimize
        children = @children.map(&:optimize)
        index = 0
        while index < children.size - 1
          if children[index].chains_with?(children[index + 1])
            children[index] = children[index].chain(children[index + 1])
            children.delete_at(index + 1)
          else
            index += 1
          end
        end
        Chain.new(children)
      end
    end
  end
end
