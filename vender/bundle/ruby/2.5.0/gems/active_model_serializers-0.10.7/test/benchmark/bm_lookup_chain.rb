require_relative './benchmarking_support'
require_relative './app'

time = 10
disable_gc = true
ActiveModelSerializers.config.key_transform = :unaltered

module AmsBench
  module Api
    module V1
      class PrimaryResourceSerializer < ActiveModel::Serializer
        attributes :title, :body

        has_many :has_many_relationships
      end

      class HasManyRelationshipSerializer < ActiveModel::Serializer
        attribute :body
      end
    end
  end
  class PrimaryResourceSerializer < ActiveModel::Serializer
    attributes :title, :body

    has_many :has_many_relationships

    class HasManyRelationshipSerializer < ActiveModel::Serializer
      attribute :body
    end
  end
end

resource = PrimaryResource.new(
  id: 1,
  title: 'title',
  body: 'body',
  has_many_relationships: [
    HasManyRelationship.new(id: 1, body: 'body1'),
    HasManyRelationship.new(id: 2, body: 'body1')
  ]
)

serialization = lambda do
  ActiveModelSerializers::SerializableResource.new(resource, serializer: AmsBench::PrimaryResourceSerializer).as_json
  ActiveModelSerializers::SerializableResource.new(resource, namespace: AmsBench::Api::V1).as_json
  ActiveModelSerializers::SerializableResource.new(resource).as_json
end

def clear_cache
  AmsBench::PrimaryResourceSerializer.serializers_cache.clear
  AmsBench::Api::V1::PrimaryResourceSerializer.serializers_cache.clear
  ActiveModel::Serializer.serializers_cache.clear
end

configurable = lambda do
  clear_cache
  Benchmark.ams('Configurable Lookup Chain', time: time, disable_gc: disable_gc, &serialization)
end

old = lambda do
  clear_cache
  module ActiveModel
    class Serializer
      def self.serializer_lookup_chain_for(klass, namespace = nil)
        chain = []

        resource_class_name = klass.name.demodulize
        resource_namespace = klass.name.deconstantize
        serializer_class_name = "#{resource_class_name}Serializer"

        chain.push("#{namespace}::#{serializer_class_name}") if namespace
        chain.push("#{name}::#{serializer_class_name}") if self != ActiveModel::Serializer
        chain.push("#{resource_namespace}::#{serializer_class_name}")
        chain
      end
    end
  end

  Benchmark.ams('Old Lookup Chain (v0.10)', time: time, disable_gc: disable_gc, &serialization)
end

configurable.call
old.call
