module ActiveModelSerializers
  module Adapter
    class JsonApi
      class Relationship
        # {http://jsonapi.org/format/#document-resource-object-related-resource-links Document Resource Object Related Resource Links}
        # {http://jsonapi.org/format/#document-links Document Links}
        # {http://jsonapi.org/format/#document-resource-object-linkage Document Resource Relationship Linkage}
        # {http://jsonapi.org/format/#document-meta Document Meta}
        def initialize(parent_serializer, serializable_resource_options, association)
          @parent_serializer = parent_serializer
          @association = association
          @serializable_resource_options = serializable_resource_options
        end

        def as_json
          hash = {}

          hash[:data] = data_for(association) if association.include_data?

          links = links_for(association)
          hash[:links] = links if links.any?

          meta = meta_for(association)
          hash[:meta] = meta if meta
          hash[:meta] = {} if hash.empty?

          hash
        end

        protected

        attr_reader :parent_serializer, :serializable_resource_options, :association

        private

        # TODO(BF): Avoid db hit on belong_to_ releationship by using foreign_key on self
        def data_for(association)
          if association.collection?
            data_for_many(association)
          else
            data_for_one(association)
          end
        end

        def data_for_one(association)
          if belongs_to_id_on_self?(association)
            id = parent_serializer.read_attribute_for_serialization(association.reflection.foreign_key)
            type =
              if association.polymorphic?
                # We can't infer resource type for polymorphic relationships from the serializer.
                # We can ONLY know a polymorphic resource type by inspecting each resource.
                association.lazy_association.serializer.json_key
              else
                association.reflection.type.to_s
              end
            ResourceIdentifier.for_type_with_id(type, id, serializable_resource_options)
          else
            # TODO(BF): Process relationship without evaluating lazy_association
            serializer = association.lazy_association.serializer
            if (virtual_value = association.virtual_value)
              virtual_value
            elsif serializer && association.object
              ResourceIdentifier.new(serializer, serializable_resource_options).as_json
            else
              nil
            end
          end
        end

        def data_for_many(association)
          # TODO(BF): Process relationship without evaluating lazy_association
          collection_serializer = association.lazy_association.serializer
          if collection_serializer.respond_to?(:each)
            collection_serializer.map do |serializer|
              ResourceIdentifier.new(serializer, serializable_resource_options).as_json
            end
          elsif (virtual_value = association.virtual_value)
            virtual_value
          else
            []
          end
        end

        def links_for(association)
          association.links.each_with_object({}) do |(key, value), hash|
            result = Link.new(parent_serializer, value).as_json
            hash[key] = result if result
          end
        end

        def meta_for(association)
          meta = association.meta
          meta.respond_to?(:call) ? parent_serializer.instance_eval(&meta) : meta
        end

        def belongs_to_id_on_self?(association)
          parent_serializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship &&
            association.belongs_to? &&
            parent_serializer.object.respond_to?(association.reflection.foreign_key)
        end
      end
    end
  end
end
