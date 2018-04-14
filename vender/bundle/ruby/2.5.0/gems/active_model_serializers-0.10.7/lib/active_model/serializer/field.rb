module ActiveModel
  class Serializer
    # Holds all the meta-data about a field (i.e. attribute or association) as it was
    # specified in the ActiveModel::Serializer class.
    # Notice that the field block is evaluated in the context of the serializer.
    Field = Struct.new(:name, :options, :block) do
      def initialize(*)
        super

        validate_condition!
      end

      # Compute the actual value of a field for a given serializer instance.
      # @param [Serializer] The serializer instance for which the value is computed.
      # @return [Object] value
      #
      # @api private
      #
      def value(serializer)
        if block
          serializer.instance_eval(&block)
        else
          serializer.read_attribute_for_serialization(name)
        end
      end

      # Decide whether the field should be serialized by the given serializer instance.
      # @param [Serializer] The serializer instance
      # @return [Bool]
      #
      # @api private
      #
      def excluded?(serializer)
        case condition_type
        when :if
          !evaluate_condition(serializer)
        when :unless
          evaluate_condition(serializer)
        else
          false
        end
      end

      private

      def validate_condition!
        return if condition_type == :none

        case condition
        when Symbol, String, Proc
          # noop
        else
          fail TypeError, "#{condition_type.inspect} should be a Symbol, String or Proc"
        end
      end

      def evaluate_condition(serializer)
        case condition
        when Symbol
          serializer.public_send(condition)
        when String
          serializer.instance_eval(condition)
        when Proc
          if condition.arity.zero?
            serializer.instance_exec(&condition)
          else
            serializer.instance_exec(serializer, &condition)
          end
        else
          nil
        end
      end

      def condition_type
        @condition_type ||=
          if options.key?(:if)
            :if
          elsif options.key?(:unless)
            :unless
          else
            :none
          end
      end

      def condition
        options[condition_type]
      end
    end
  end
end
