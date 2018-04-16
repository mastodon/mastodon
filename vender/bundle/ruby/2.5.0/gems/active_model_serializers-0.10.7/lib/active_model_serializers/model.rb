# ActiveModelSerializers::Model is a convenient superclass for making your models
# from Plain-Old Ruby Objects (PORO). It also serves as a reference implementation
# that satisfies ActiveModel::Serializer::Lint::Tests.
require 'active_support/core_ext/hash'
module ActiveModelSerializers
  class Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    # Declare names of attributes to be included in +attributes+ hash.
    # Is only available as a class-method since the ActiveModel::Serialization mixin in Rails
    # uses an +attribute_names+ local variable, which may conflict if we were to add instance methods here.
    #
    # @overload attribute_names
    #   @return [Array<Symbol>]
    class_attribute :attribute_names, instance_writer: false, instance_reader: false
    # Initialize +attribute_names+ for all subclasses.  The array is usually
    # mutated in the +attributes+ method, but can be set directly, as well.
    self.attribute_names = []

    # Easily declare instance attributes with setters and getters for each.
    #
    # To initialize an instance, all attributes must have setters.
    # However, the hash returned by +attributes+ instance method will ALWAYS
    # be the value of the initial attributes, regardless of what accessors are defined.
    # The only way to change the change the attributes after initialization is
    # to mutate the +attributes+ directly.
    # Accessor methods do NOT mutate the attributes.  (This is a bug).
    #
    # @note For now, the Model only supports the notion of 'attributes'.
    #   In the tests, there is a special Model that also supports 'associations'. This is
    #   important so that we can add accessors for values that should not appear in the
    #   attributes hash when modeling associations. It is not yet clear if it
    #   makes sense for a PORO to have associations outside of the tests.
    #
    # @overload attributes(names)
    #   @param names [Array<String, Symbol>]
    #   @param name [String, Symbol]
    def self.attributes(*names)
      self.attribute_names |= names.map(&:to_sym)
      # Silence redefinition of methods warnings
      ActiveModelSerializers.silence_warnings do
        attr_accessor(*names)
      end
    end

    # Opt-in to breaking change
    def self.derive_attributes_from_names_and_fix_accessors
      unless included_modules.include?(DeriveAttributesFromNamesAndFixAccessors)
        prepend(DeriveAttributesFromNamesAndFixAccessors)
      end
    end

    module DeriveAttributesFromNamesAndFixAccessors
      def self.included(base)
        # NOTE that +id+ will always be in +attributes+.
        base.attributes :id
      end

      # Override the +attributes+ method so that the hash is derived from +attribute_names+.
      #
      # The fields in +attribute_names+ determines the returned hash.
      # +attributes+ are returned frozen to prevent any expectations that mutation affects
      # the actual values in the model.
      def attributes
        self.class.attribute_names.each_with_object({}) do |attribute_name, result|
          result[attribute_name] = public_send(attribute_name).freeze
        end.with_indifferent_access.freeze
      end
    end

    # Support for validation and other ActiveModel::Errors
    # @return [ActiveModel::Errors]
    attr_reader :errors

    # (see #updated_at)
    attr_writer :updated_at

    # The only way to change the attributes of an instance is to directly mutate the attributes.
    # @example
    #
    #   model.attributes[:foo] = :bar
    # @return [Hash]
    attr_reader :attributes

    # @param attributes [Hash]
    def initialize(attributes = {})
      attributes ||= {} # protect against nil
      @attributes = attributes.symbolize_keys.with_indifferent_access
      @errors = ActiveModel::Errors.new(self)
      super
    end

    # Defaults to the downcased model name.
    # This probably isn't a good default, since it's not a unique instance identifier,
    # but that's what is currently implemented \_('-')_/.
    #
    # @note Though +id+ is defined, it will only show up
    #   in +attributes+ when it is passed in to the initializer or added to +attributes+,
    #   such as <tt>attributes[:id] = 5</tt>.
    # @return [String, Numeric, Symbol]
    def id
      attributes.fetch(:id) do
        defined?(@id) ? @id : self.class.model_name.name && self.class.model_name.name.downcase
      end
    end

    # When not set, defaults to the time the file was modified.
    #
    # @note Though +updated_at+ and +updated_at=+ are defined, it will only show up
    #   in +attributes+ when it is passed in to the initializer or added to +attributes+,
    #   such as <tt>attributes[:updated_at] = Time.current</tt>.
    # @return [String, Numeric, Time]
    def updated_at
      attributes.fetch(:updated_at) do
        defined?(@updated_at) ? @updated_at : File.mtime(__FILE__)
      end
    end

    # To customize model behavior, this method must be redefined. However,
    # there are other ways of setting the +cache_key+ a serializer uses.
    # @return [String]
    def cache_key
      ActiveSupport::Cache.expand_cache_key([
        self.class.model_name.name.downcase,
        "#{id}-#{updated_at.strftime('%Y%m%d%H%M%S%9N')}"
      ].compact)
    end
  end
end
