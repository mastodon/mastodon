module JMESPath
  # @api private
  module Nodes
    class MultiSelectHash < Node
      def initialize(kv_pairs)
        @kv_pairs = kv_pairs
      end

      def visit(value)
        if value.nil?
          nil
        else
          @kv_pairs.each_with_object({}) do |pair, hash|
            hash[pair.key] = pair.value.visit(value)
          end
        end
      end

      def optimize
        self.class.new(@kv_pairs.map(&:optimize))
      end

      class KeyValuePair
        attr_reader :key, :value

        def initialize(key, value)
          @key = key
          @value = value
        end

        def optimize
          self.class.new(@key, @value.optimize)
        end
      end
    end
  end
end
