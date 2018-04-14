module ActiveModelSerializers
  module LookupChain
    # Standard appending of Serializer to the resource name.
    #
    # Example:
    #   Author => AuthorSerializer
    BY_RESOURCE = lambda do |resource_class, _serializer_class, _namespace|
      serializer_from(resource_class)
    end

    # Uses the namespace of the resource to find the serializer
    #
    # Example:
    #  British::Author => British::AuthorSerializer
    BY_RESOURCE_NAMESPACE = lambda do |resource_class, _serializer_class, _namespace|
      resource_namespace = namespace_for(resource_class)
      serializer_name = serializer_from(resource_class)

      "#{resource_namespace}::#{serializer_name}"
    end

    # Uses the controller namespace of the resource to find the serializer
    #
    # Example:
    #  Api::V3::AuthorsController => Api::V3::AuthorSerializer
    BY_NAMESPACE = lambda do |resource_class, _serializer_class, namespace|
      resource_name = resource_class_name(resource_class)
      namespace ? "#{namespace}::#{resource_name}Serializer" : nil
    end

    # Allows for serializers to be defined in parent serializers
    # - useful if a relationship only needs a different set of attributes
    #   than if it were rendered independently.
    #
    # Example:
    #   class BlogSerializer < ActiveModel::Serializer
    #     class AuthorSerialier < ActiveModel::Serializer
    #     ...
    #     end
    #
    #     belongs_to :author
    #     ...
    #   end
    #
    #  The belongs_to relationship would be rendered with
    #    BlogSerializer::AuthorSerialier
    BY_PARENT_SERIALIZER = lambda do |resource_class, serializer_class, _namespace|
      return if serializer_class == ActiveModel::Serializer

      serializer_name = serializer_from(resource_class)
      "#{serializer_class}::#{serializer_name}"
    end

    DEFAULT = [
      BY_PARENT_SERIALIZER,
      BY_NAMESPACE,
      BY_RESOURCE_NAMESPACE,
      BY_RESOURCE
    ].freeze

    module_function

    def namespace_for(klass)
      klass.name.deconstantize
    end

    def resource_class_name(klass)
      klass.name.demodulize
    end

    def serializer_from_resource_name(name)
      "#{name}Serializer"
    end

    def serializer_from(klass)
      name = resource_class_name(klass)
      serializer_from_resource_name(name)
    end
  end
end
