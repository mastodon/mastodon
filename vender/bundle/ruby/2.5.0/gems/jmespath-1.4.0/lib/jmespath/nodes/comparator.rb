module JMESPath
  # @api private
  module Nodes
    class Comparator < Node
      attr_reader :left, :right

      def initialize(left, right)
        @left = left
        @right = right
      end

      def self.create(relation, left, right)
        type = begin
          case relation
          when '==' then Comparators::Eq
          when '!=' then Comparators::Neq
          when '>' then Comparators::Gt
          when '>=' then Comparators::Gte
          when '<' then Comparators::Lt
          when '<=' then Comparators::Lte
          end
        end
        type.new(left, right)
      end

      def visit(value)
        check(@left.visit(value), @right.visit(value))
      end

      def optimize
        self.class.new(@left.optimize, @right.optimize)
      end

      private

      def check(left_value, right_value)
        nil
      end
    end

    module Comparators

      class Eq < Comparator
        def check(left_value, right_value)
          left_value == right_value
        end
      end

      class Neq < Comparator
        def check(left_value, right_value)
          left_value != right_value
        end
      end

      class Gt < Comparator
        def check(left_value, right_value)
          if left_value.is_a?(Numeric) && right_value.is_a?(Numeric)
            left_value > right_value
          else
            nil
          end
        end
      end

      class Gte < Comparator
        def check(left_value, right_value)
          if left_value.is_a?(Numeric) && right_value.is_a?(Numeric)
            left_value >= right_value
          else
            nil
          end
        end
      end

      class Lt < Comparator
        def check(left_value, right_value)
          if left_value.is_a?(Numeric) && right_value.is_a?(Numeric)
            left_value < right_value
          else
            nil
          end
        end
      end

      class Lte < Comparator
        def check(left_value, right_value)
          if left_value.is_a?(Numeric) && right_value.is_a?(Numeric)
            left_value <= right_value
          else
            nil
          end
        end
      end
    end
  end
end
