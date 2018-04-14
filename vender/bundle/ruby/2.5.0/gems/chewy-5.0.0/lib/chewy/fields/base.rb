module Chewy
  module Fields
    class Base
      attr_reader :name, :options, :value, :children
      attr_accessor :parent

      def initialize(name, value: nil, **options)
        @name = name.to_sym
        @options = {}
        update_options!(options)
        @value = value
        @children = []
      end

      def update_options!(**options)
        @options = options
      end

      def multi_field?
        children.present? && !object_field?
      end

      def object_field?
        (children.present? && options[:type].blank?) || %w[object nested].include?(options[:type].to_s)
      end

      def mappings_hash
        mapping =
          if children.present?
            {(multi_field? ? :fields : :properties) => children.map(&:mappings_hash).inject(:merge)}
          else
            {}
          end
        mapping.reverse_merge!(options)
        mapping.reverse_merge!(type: (children.present? ? 'object' : Chewy.default_field_type))

        # This is done to support ES2 journaling and will be removed soon
        if mapping[:type] == 'keyword' && Chewy::Runtime.version < '5.0'
          mapping[:type] = 'string'
          mapping[:index] = 'not_analyzed'
        end

        {name => mapping}
      end

      def compose(*objects)
        result = evaluate(objects)

        if children.present? && !multi_field?
          result = if result.respond_to?(:to_ary)
            result.to_ary.map { |item| compose_children(item, *objects) }
          else
            compose_children(result, *objects)
          end
        end

        {name => result}
      end

    private

      def evaluate(objects)
        object = objects.first

        if value.is_a?(Proc)
          if value.arity.zero?
            object.instance_exec(&value)
          elsif value.arity < 0
            value.call(*object)
          else
            value.call(*objects.first(value.arity))
          end
        else
          message = value.is_a?(Symbol) || value.is_a?(String) ? value.to_sym : name

          if object.is_a?(Hash)
            if object.key?(message)
              object[message]
            else
              object[message.to_s]
            end
          else
            object.send(message)
          end
        end
      end

      def compose_children(value, *parent_objects)
        return unless value

        children.each_with_object({}) do |field, result|
          result.merge!(field.compose(value, *parent_objects) || {})
        end
      end
    end
  end
end
