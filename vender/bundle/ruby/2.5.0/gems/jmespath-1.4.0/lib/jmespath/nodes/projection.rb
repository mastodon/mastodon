module JMESPath
  # @api private
  module Nodes
    class Projection < Node
      def initialize(target, projection)
        @target = target
        @projection = projection
      end

      def visit(value)
        if (targets = extract_targets(@target.visit(value)))
          list = []
          targets.each do |v|
            vv = @projection.visit(v)
            unless vv.nil?
              list << vv
            end
          end
          list
        end
      end

      def optimize
        if @projection.is_a?(Current)
          fast_instance
        else
          self.class.new(@target.optimize, @projection.optimize)
        end
      end

      private

      def extract_targets(left_value)
        nil
      end
    end

    module FastProjector
      def visit(value)
        if (targets = extract_targets(@target.visit(value)))
          targets.compact
        end
      end
    end

    class ArrayProjection < Projection
      def extract_targets(target)
        if Array === target
          target
        else
          nil
        end
      end

      def fast_instance
        FastArrayProjection.new(@target.optimize, @projection.optimize)
      end
    end

    class FastArrayProjection < ArrayProjection
      include FastProjector
    end

    class ObjectProjection < Projection
      def extract_targets(target)
        if hash_like?(target)
          target.values
        else
          nil
        end
      end

      def fast_instance
        FastObjectProjection.new(@target.optimize, @projection.optimize)
      end
    end

    class FastObjectProjection < ObjectProjection
      include FastProjector
    end
  end
end
