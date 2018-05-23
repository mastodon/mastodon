module ActiveModelSerializers
  module Adapter
    class JsonApi
      # meta
      # definition:
      #   JSON Object
      #
      # description:
      #   Non-standard meta-information that can not be represented as an attribute or relationship.
      # structure:
      #   {
      #     attitude: 'adjustable'
      #   }
      class Meta
        def initialize(serializer)
          @object = serializer.object
          @scope = serializer.scope

          # Use the return value of the block unless it is nil.
          if serializer._meta.respond_to?(:call)
            @value = instance_eval(&serializer._meta)
          else
            @value = serializer._meta
          end
        end

        def as_json
          @value
        end

        protected

        attr_reader :object, :scope
      end
    end
  end
end
