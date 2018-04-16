module ActiveModelSerializers
  module Adapter
    class Json < Base
      def serializable_hash(options = nil)
        options = serialization_options(options)
        serialized_hash = { root => Attributes.new(serializer, instance_options).serializable_hash(options) }
        serialized_hash[meta_key] = meta unless meta.blank?

        self.class.transform_key_casing!(serialized_hash, instance_options)
      end

      def meta
        instance_options.fetch(:meta, nil)
      end

      def meta_key
        instance_options.fetch(:meta_key, 'meta'.freeze)
      end
    end
  end
end
