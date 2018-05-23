require 'thread_safe'
require 'jsonapi/include_directive'
require 'active_model/serializer/collection_serializer'
require 'active_model/serializer/array_serializer'
require 'active_model/serializer/error_serializer'
require 'active_model/serializer/errors_serializer'
require 'active_model/serializer/concerns/caching'
require 'active_model/serializer/fieldset'
require 'active_model/serializer/lint'

# ActiveModel::Serializer is an abstract class that is
# reified when subclassed to decorate a resource.
module ActiveModel
  class Serializer
    undef_method :select, :display # These IO methods, which are mixed into Kernel,
    # sometimes conflict with attribute names. We don't need these IO methods.

    # @see #serializable_hash for more details on these valid keys.
    SERIALIZABLE_HASH_VALID_KEYS = [:only, :except, :methods, :include, :root].freeze
    extend ActiveSupport::Autoload
    autoload :Adapter
    autoload :Null
    autoload :Attribute
    autoload :Association
    autoload :Reflection
    autoload :SingularReflection
    autoload :CollectionReflection
    autoload :BelongsToReflection
    autoload :HasOneReflection
    autoload :HasManyReflection
    include ActiveSupport::Configurable
    include Caching

    # @param resource [ActiveRecord::Base, ActiveModelSerializers::Model]
    # @return [ActiveModel::Serializer]
    #   Preferentially returns
    #   1. resource.serializer_class
    #   2. ArraySerializer when resource is a collection
    #   3. options[:serializer]
    #   4. lookup serializer when resource is a Class
    def self.serializer_for(resource_or_class, options = {})
      if resource_or_class.respond_to?(:serializer_class)
        resource_or_class.serializer_class
      elsif resource_or_class.respond_to?(:to_ary)
        config.collection_serializer
      else
        resource_class = resource_or_class.class == Class ? resource_or_class : resource_or_class.class
        options.fetch(:serializer) { get_serializer_for(resource_class, options[:namespace]) }
      end
    end

    # @see ActiveModelSerializers::Adapter.lookup
    # Deprecated
    def self.adapter
      ActiveModelSerializers::Adapter.lookup(config.adapter)
    end
    class << self
      extend ActiveModelSerializers::Deprecate
      deprecate :adapter, 'ActiveModelSerializers::Adapter.configured_adapter'
    end

    # @api private
    def self.serializer_lookup_chain_for(klass, namespace = nil)
      lookups = ActiveModelSerializers.config.serializer_lookup_chain
      Array[*lookups].flat_map do |lookup|
        lookup.call(klass, self, namespace)
      end.compact
    end

    # Used to cache serializer name => serializer class
    # when looked up by Serializer.get_serializer_for.
    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

    # @api private
    # Find a serializer from a class and caches the lookup.
    # Preferentially returns:
    #   1. class name appended with "Serializer"
    #   2. try again with superclass, if present
    #   3. nil
    def self.get_serializer_for(klass, namespace = nil)
      return nil unless config.serializer_lookup_enabled

      cache_key = ActiveSupport::Cache.expand_cache_key(klass, namespace)
      serializers_cache.fetch_or_store(cache_key) do
        # NOTE(beauby): When we drop 1.9.3 support we can lazify the map for perfs.
        lookup_chain = serializer_lookup_chain_for(klass, namespace)
        serializer_class = lookup_chain.map(&:safe_constantize).find { |x| x && x < ActiveModel::Serializer }

        if serializer_class
          serializer_class
        elsif klass.superclass
          get_serializer_for(klass.superclass)
        else
          nil # No serializer found
        end
      end
    end

    # @api private
    def self.include_directive_from_options(options)
      if options[:include_directive]
        options[:include_directive]
      elsif options[:include]
        JSONAPI::IncludeDirective.new(options[:include], allow_wildcard: true)
      else
        ActiveModelSerializers.default_include_directive
      end
    end

    # @api private
    def self.serialization_adapter_instance
      @serialization_adapter_instance ||= ActiveModelSerializers::Adapter::Attributes
    end

    # Preferred interface is ActiveModelSerializers.config
    # BEGIN DEFAULT CONFIGURATION
    config.collection_serializer = ActiveModel::Serializer::CollectionSerializer
    config.serializer_lookup_enabled = true

    # @deprecated Use {#config.collection_serializer=} instead of this. Is
    #   compatibility layer for ArraySerializer.
    def config.array_serializer=(collection_serializer)
      self.collection_serializer = collection_serializer
    end

    # @deprecated Use {#config.collection_serializer} instead of this. Is
    #   compatibility layer for ArraySerializer.
    def config.array_serializer
      collection_serializer
    end

    config.default_includes = '*'
    config.adapter = :attributes
    config.key_transform = nil
    config.jsonapi_pagination_links_enabled = true
    config.jsonapi_resource_type = :plural
    config.jsonapi_namespace_separator = '-'.freeze
    config.jsonapi_version = '1.0'
    config.jsonapi_toplevel_meta = {}
    # Make JSON API top-level jsonapi member opt-in
    # ref: http://jsonapi.org/format/#document-top-level
    config.jsonapi_include_toplevel_object = false
    config.jsonapi_use_foreign_key_on_belongs_to_relationship = false
    config.include_data_default = true

    # For configuring how serializers are found.
    # This should be an array of procs.
    #
    # The priority of the output is that the first item
    # in the evaluated result array will take precedence
    # over other possible serializer paths.
    #
    # i.e.: First match wins.
    #
    # @example output
    # => [
    #   "CustomNamespace::ResourceSerializer",
    #   "ParentSerializer::ResourceSerializer",
    #   "ResourceNamespace::ResourceSerializer" ,
    #   "ResourceSerializer"]
    #
    # If CustomNamespace::ResourceSerializer exists, it will be used
    # for serialization
    config.serializer_lookup_chain = ActiveModelSerializers::LookupChain::DEFAULT.dup

    config.schema_path = 'test/support/schemas'
    # END DEFAULT CONFIGURATION

    with_options instance_writer: false, instance_reader: false do |serializer|
      serializer.class_attribute :_attributes_data # @api private
      self._attributes_data ||= {}
    end
    with_options instance_writer: false, instance_reader: true do |serializer|
      serializer.class_attribute :_reflections
      self._reflections ||= {}
      serializer.class_attribute :_links # @api private
      self._links ||= {}
      serializer.class_attribute :_meta # @api private
      serializer.class_attribute :_type # @api private
    end

    def self.inherited(base)
      super
      base._attributes_data = _attributes_data.dup
      base._reflections = _reflections.dup
      base._links = _links.dup
    end

    # @return [Array<Symbol>] Key names of declared attributes
    # @see Serializer::attribute
    def self._attributes
      _attributes_data.keys
    end

    # BEGIN SERIALIZER MACROS

    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     attributes :id, :name, :recent_edits
    def self.attributes(*attrs)
      attrs = attrs.first if attrs.first.class == Array

      attrs.each do |attr|
        attribute(attr)
      end
    end

    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     attributes :id, :recent_edits
    #     attribute :name, key: :title
    #
    #     attribute :full_name do
    #       "#{object.first_name} #{object.last_name}"
    #     end
    #
    #     def recent_edits
    #       object.edits.last(5)
    #     end
    def self.attribute(attr, options = {}, &block)
      key = options.fetch(:key, attr)
      _attributes_data[key] = Attribute.new(attr, options, block)
    end

    # @param [Symbol] name of the association
    # @param [Hash<Symbol => any>] options for the reflection
    # @return [void]
    #
    # @example
    #  has_many :comments, serializer: CommentSummarySerializer
    #
    def self.has_many(name, options = {}, &block) # rubocop:disable Style/PredicateName
      associate(HasManyReflection.new(name, options, block))
    end

    # @param [Symbol] name of the association
    # @param [Hash<Symbol => any>] options for the reflection
    # @return [void]
    #
    # @example
    #  belongs_to :author, serializer: AuthorSerializer
    #
    def self.belongs_to(name, options = {}, &block)
      associate(BelongsToReflection.new(name, options, block))
    end

    # @param [Symbol] name of the association
    # @param [Hash<Symbol => any>] options for the reflection
    # @return [void]
    #
    # @example
    #  has_one :author, serializer: AuthorSerializer
    #
    def self.has_one(name, options = {}, &block) # rubocop:disable Style/PredicateName
      associate(HasOneReflection.new(name, options, block))
    end

    # Add reflection and define {name} accessor.
    # @param [ActiveModel::Serializer::Reflection] reflection
    # @return [void]
    #
    # @api private
    def self.associate(reflection)
      key = reflection.options[:key] || reflection.name
      self._reflections[key] = reflection
    end
    private_class_method :associate

    # Define a link on a serializer.
    # @example
    #   link(:self) { resource_url(object) }
    # @example
    #   link(:self) { "http://example.com/resource/#{object.id}" }
    # @example
    #   link :resource, "http://example.com/resource"
    #
    def self.link(name, value = nil, &block)
      _links[name] = block || value
    end

    # Set the JSON API meta attribute of a serializer.
    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     meta { stuff: 'value' }
    # @example
    #     meta do
    #       { comment_count: object.comments.count }
    #     end
    def self.meta(value = nil, &block)
      self._meta = block || value
    end

    # Set the JSON API type of a serializer.
    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     type 'authors'
    def self.type(type)
      self._type = type && type.to_s
    end

    # END SERIALIZER MACROS

    attr_accessor :object, :root, :scope

    # `scope_name` is set as :current_user by default in the controller.
    # If the instance does not have a method named `scope_name`, it
    # defines the method so that it calls the +scope+.
    def initialize(object, options = {})
      self.object = object
      self.instance_options = options
      self.root = instance_options[:root]
      self.scope = instance_options[:scope]

      return if !(scope_name = instance_options[:scope_name]) || respond_to?(scope_name)

      define_singleton_method scope_name, -> { scope }
    end

    def success?
      true
    end

    # Return the +attributes+ of +object+ as presented
    # by the serializer.
    def attributes(requested_attrs = nil, reload = false)
      @attributes = nil if reload
      @attributes ||= self.class._attributes_data.each_with_object({}) do |(key, attr), hash|
        next if attr.excluded?(self)
        next unless requested_attrs.nil? || requested_attrs.include?(key)
        hash[key] = attr.value(self)
      end
    end

    # @param [JSONAPI::IncludeDirective] include_directive (defaults to the
    #   +default_include_directive+ config value when not provided)
    # @return [Enumerator<Association>]
    def associations(include_directive = ActiveModelSerializers.default_include_directive, include_slice = nil)
      include_slice ||= include_directive
      return Enumerator.new {} unless object

      Enumerator.new do |y|
        self.class._reflections.each do |key, reflection|
          next if reflection.excluded?(self)
          next unless include_directive.key?(key)

          association = reflection.build_association(self, instance_options, include_slice)
          y.yield association
        end
      end
    end

    # @return [Hash] containing the attributes and first level
    # associations, similar to how ActiveModel::Serializers::JSON is used
    # in ActiveRecord::Base.
    def serializable_hash(adapter_options = nil, options = {}, adapter_instance = self.class.serialization_adapter_instance)
      adapter_options ||= {}
      options[:include_directive] ||= ActiveModel::Serializer.include_directive_from_options(adapter_options)
      resource = attributes_hash(adapter_options, options, adapter_instance)
      relationships = associations_hash(adapter_options, options, adapter_instance)
      resource.merge(relationships)
    end
    alias to_hash serializable_hash
    alias to_h serializable_hash

    # @see #serializable_hash
    def as_json(adapter_opts = nil)
      serializable_hash(adapter_opts)
    end

    # Used by adapter as resource root.
    def json_key
      root || _type || object.class.model_name.to_s.underscore
    end

    def read_attribute_for_serialization(attr)
      if respond_to?(attr)
        send(attr)
      else
        object.read_attribute_for_serialization(attr)
      end
    end

    # @api private
    def attributes_hash(_adapter_options, options, adapter_instance)
      if self.class.cache_enabled?
        fetch_attributes(options[:fields], options[:cached_attributes] || {}, adapter_instance)
      elsif self.class.fragment_cache_enabled?
        fetch_attributes_fragment(adapter_instance, options[:cached_attributes] || {})
      else
        attributes(options[:fields], true)
      end
    end

    # @api private
    def associations_hash(adapter_options, options, adapter_instance)
      include_directive = options.fetch(:include_directive)
      include_slice = options[:include_slice]
      associations(include_directive, include_slice).each_with_object({}) do |association, relationships|
        adapter_opts = adapter_options.merge(include_directive: include_directive[association.key], adapter_instance: adapter_instance)
        relationships[association.key] = association.serializable_hash(adapter_opts, adapter_instance)
      end
    end

    protected

    attr_accessor :instance_options
  end
end
