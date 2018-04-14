require 'hashie/hash'
require 'set'

module Hashie
  # A Dash is a 'defined' or 'discrete' Hash, that is, a Hash
  # that has a set of defined keys that are accessible (with
  # optional defaults) and only those keys may be set or read.
  #
  # Dashes are useful when you need to create a very simple
  # lightweight data object that needs even fewer options and
  # resources than something like a DataMapper resource.
  #
  # It is preferrable to a Struct because of the in-class
  # API for defining properties as well as per-property defaults.
  class Dash < Hash
    include Hashie::Extensions::PrettyInspect

    alias_method :to_s, :inspect

    # Defines a property on the Dash. Options are
    # as follows:
    #
    # * <tt>:default</tt> - Specify a default value for this property,
    #   to be returned before a value is set on the property in a new
    #   Dash.
    #
    # * <tt>:required</tt> - Specify the value as required for this
    #   property, to raise an error if a value is unset in a new or
    #   existing Dash. If a Proc is provided, it will be run in the
    #   context of the Dash instance. If a Symbol is provided, the
    #   property it represents must not be nil. The property is only
    #   required if the value is truthy.
    #
    # * <tt>:message</tt> - Specify custom error message for required property
    #
    def self.property(property_name, options = {})
      properties << property_name

      if options.key?(:default)
        defaults[property_name] = options[:default]
      elsif defaults.key?(property_name)
        defaults.delete property_name
      end

      unless instance_methods.map(&:to_s).include?("#{property_name}=")
        define_method(property_name) { |&block| self.[](property_name, &block) }
        property_assignment = "#{property_name}=".to_sym
        define_method(property_assignment) { |value| self.[]=(property_name, value) }
      end

      if defined? @subclasses
        @subclasses.each { |klass| klass.property(property_name, options) }
      end

      condition = options.delete(:required)
      if condition
        message = options.delete(:message) || "is required for #{name}."
        required_properties[property_name] = { condition: condition, message: message }
      else
        fail ArgumentError, 'The :message option should be used with :required option.' if options.key?(:message)
      end
    end

    class << self
      attr_reader :properties, :defaults
      attr_reader :required_properties
    end
    instance_variable_set('@properties', Set.new)
    instance_variable_set('@defaults', {})
    instance_variable_set('@required_properties', {})

    def self.inherited(klass)
      super
      (@subclasses ||= Set.new) << klass
      klass.instance_variable_set('@properties', properties.dup)
      klass.instance_variable_set('@defaults', defaults.dup)
      klass.instance_variable_set('@required_properties', required_properties.dup)
    end

    # Check to see if the specified property has already been
    # defined.
    def self.property?(name)
      properties.include? name
    end

    # Check to see if the specified property is
    # required.
    def self.required?(name)
      required_properties.key? name
    end

    # You may initialize a Dash with an attributes hash
    # just like you would many other kinds of data objects.
    def initialize(attributes = {}, &block)
      super(&block)

      self.class.defaults.each_pair do |prop, value|
        self[prop] = begin
          val = value.dup
          if val.is_a?(Proc)
            val.arity == 1 ? val.call(self) : val.call
          else
            val
          end
        rescue TypeError
          value
        end
      end

      initialize_attributes(attributes)
      assert_required_attributes_set!
    end

    alias_method :_regular_reader, :[]
    alias_method :_regular_writer, :[]=
    private :_regular_reader, :_regular_writer

    # Retrieve a value from the Dash (will return the
    # property's default value if it hasn't been set).
    def [](property)
      assert_property_exists! property
      value = super(property)
      # If the value is a lambda, proc, or whatever answers to call, eval the thing!
      if value.is_a? Proc
        self[property] = value.call # Set the result of the call as a value
      else
        yield value if block_given?
        value
      end
    end

    # Set a value on the Dash in a Hash-like way. Only works
    # on pre-existing properties.
    def []=(property, value)
      assert_property_required! property, value
      assert_property_exists! property
      super(property, value)
    end

    def merge(other_hash)
      new_dash = dup
      other_hash.each do |k, v|
        new_dash[k] = block_given? ? yield(k, self[k], v) : v
      end
      new_dash
    end

    def merge!(other_hash)
      other_hash.each do |k, v|
        self[k] = block_given? ? yield(k, self[k], v) : v
      end
      self
    end

    def replace(other_hash)
      other_hash = self.class.defaults.merge(other_hash)
      (keys - other_hash.keys).each { |key| delete(key) }
      other_hash.each { |key, value| self[key] = value }
      self
    end

    def update_attributes!(attributes)
      initialize_attributes(attributes)

      self.class.defaults.each_pair do |prop, value|
        self[prop] = begin
          value.dup
        rescue TypeError
          value
        end if self[prop].nil?
      end
      assert_required_attributes_set!
    end

    private

    def initialize_attributes(attributes)
      attributes.each_pair do |att, value|
        self[att] = value
      end if attributes
    end

    def assert_property_exists!(property)
      fail_no_property_error!(property) unless self.class.property?(property)
    end

    def assert_required_attributes_set!
      self.class.required_properties.each_key do |required_property|
        assert_property_set!(required_property)
      end
    end

    def assert_property_set!(property)
      fail_property_required_error!(property) if send(property).nil? && required?(property)
    end

    def assert_property_required!(property, value)
      fail_property_required_error!(property) if value.nil? && required?(property)
    end

    def fail_property_required_error!(property)
      fail ArgumentError, "The property '#{property}' #{self.class.required_properties[property][:message]}"
    end

    def fail_no_property_error!(property)
      fail NoMethodError, "The property '#{property}' is not defined for #{self.class.name}."
    end

    def required?(property)
      return false unless self.class.required?(property)

      condition = self.class.required_properties[property][:condition]
      case condition
      when Proc   then !!(instance_exec(&condition))
      when Symbol then !!(send(condition))
      else             !!(condition)
      end
    end
  end
end
