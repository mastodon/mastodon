module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def serializable_hash(options = nil)
        options = serialization_options(options)
        options[:fields] ||= instance_options[:fields]
        serialized_hash = serializer.serializable_hash(instance_options, options, self)

        self.class.transform_key_casing!(serialized_hash, instance_options)
      end
    end
  end
end
