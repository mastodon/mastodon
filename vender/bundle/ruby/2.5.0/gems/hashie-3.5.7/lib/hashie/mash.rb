require 'hashie/hash'
require 'hashie/array'
require 'hashie/utils'
require 'hashie/logger'

module Hashie
  # Mash allows you to create pseudo-objects that have method-like
  # accessors for hash keys. This is useful for such implementations
  # as an API-accessing library that wants to fake robust objects
  # without the overhead of actually doing so. Think of it as OpenStruct
  # with some additional goodies.
  #
  # A Mash will look at the methods you pass it and perform operations
  # based on the following rules:
  #
  # * No punctuation: Returns the value of the hash for that key, or nil if none exists.
  # * Assignment (<tt>=</tt>): Sets the attribute of the given method name.
  # * Existence (<tt>?</tt>): Returns true or false depending on whether that key has been set.
  # * Bang (<tt>!</tt>): Forces the existence of this key, used for deep Mashes. Think of it as "touch" for mashes.
  # * Under Bang (<tt>_</tt>): Like Bang, but returns a new Mash rather than creating a key.  Used to test existance in deep Mashes.
  #
  # == Basic Example
  #
  #   mash = Mash.new
  #   mash.name? # => false
  #   mash.name = "Bob"
  #   mash.name # => "Bob"
  #   mash.name? # => true
  #
  # == Hash Conversion  Example
  #
  #   hash = {:a => {:b => 23, :d => {:e => "abc"}}, :f => [{:g => 44, :h => 29}, 12]}
  #   mash = Mash.new(hash)
  #   mash.a.b # => 23
  #   mash.a.d.e # => "abc"
  #   mash.f.first.g # => 44
  #   mash.f.last # => 12
  #
  # == Bang Example
  #
  #   mash = Mash.new
  #   mash.author # => nil
  #   mash.author! # => <Mash>
  #
  #   mash = Mash.new
  #   mash.author!.name = "Michael Bleigh"
  #   mash.author # => <Mash name="Michael Bleigh">
  #
  # == Under Bang Example
  #
  #   mash = Mash.new
  #   mash.author # => nil
  #   mash.author_ # => <Mash>
  #   mash.author_.name # => nil
  #
  #   mash = Mash.new
  #   mash.author_.name = "Michael Bleigh"  (assigned to temp object)
  #   mash.author # => <Mash>
  #
  class Mash < Hash
    include Hashie::Extensions::PrettyInspect
    include Hashie::Extensions::RubyVersionCheck

    ALLOWED_SUFFIXES = %w(? ! = _)

    class CannotDisableMashWarnings < StandardError
      def initialize(message = 'You cannot disable warnings on the base Mash class. Please subclass the Mash and disable it in the subclass.')
        super(message)
      end
    end

    # Disable the logging of warnings based on keys conflicting keys/methods
    #
    # @api semipublic
    # @return [void]
    def self.disable_warnings
      fail CannotDisableMashWarnings if self == Hashie::Mash
      @disable_warnings = true
    end

    # Checks whether this class disables warnings for conflicting keys/methods
    #
    # @api semipublic
    # @return [Boolean]
    def self.disable_warnings?
      @disable_warnings ||= false
    end

    # Inheritance hook that sets class configuration when inherited.
    #
    # @api semipublic
    # @return [void]
    def self.inherited(subclass)
      super
      subclass.disable_warnings if disable_warnings?
    end

    def self.load(path, options = {})
      @_mashes ||= new

      return @_mashes[path] if @_mashes.key?(path)
      fail ArgumentError, "The following file doesn't exist: #{path}" unless File.file?(path)

      parser = options.fetch(:parser) {  Hashie::Extensions::Parsers::YamlErbParser }
      @_mashes[path] = new(parser.perform(path)).freeze
    end

    def to_module(mash_method_name = :settings)
      mash = self
      Module.new do |m|
        m.send :define_method, mash_method_name.to_sym do
          mash
        end
      end
    end

    alias_method :to_s, :inspect

    # If you pass in an existing hash, it will
    # convert it to a Mash including recursively
    # descending into arrays and hashes, converting
    # them as well.
    def initialize(source_hash = nil, default = nil, &blk)
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    class << self; alias_method :[], :new; end

    alias_method :regular_reader, :[]
    alias_method :regular_writer, :[]=

    # Retrieves an attribute set in the Mash. Will convert
    # any key passed in to a string before retrieving.
    def custom_reader(key)
      default_proc.call(self, key) if default_proc && !key?(key)
      value = regular_reader(convert_key(key))
      yield value if block_given?
      value
    end

    # Sets an attribute in the Mash. Key will be converted to
    # a string before it is set, and Hashes will be converted
    # into Mashes for nesting purposes.
    def custom_writer(key, value, convert = true) #:nodoc:
      key_as_symbol = (key = convert_key(key)).to_sym

      log_built_in_message(key_as_symbol) if log_collision?(key_as_symbol)
      regular_writer(key, convert ? convert_value(value) : value)
    end

    alias_method :[], :custom_reader
    alias_method :[]=, :custom_writer

    # This is the bang method reader, it will return a new Mash
    # if there isn't a value already assigned to the key requested.
    def initializing_reader(key)
      ck = convert_key(key)
      regular_writer(ck, self.class.new) unless key?(ck)
      regular_reader(ck)
    end

    # This is the under bang method reader, it will return a temporary new Mash
    # if there isn't a value already assigned to the key requested.
    def underbang_reader(key)
      ck = convert_key(key)
      if key?(ck)
        regular_reader(ck)
      else
        self.class.new
      end
    end

    def fetch(key, *args)
      super(convert_key(key), *args)
    end

    def delete(key)
      super(convert_key(key))
    end

    def values_at(*keys)
      super(*keys.map { |key| convert_key(key) })
    end

    alias_method :regular_dup, :dup
    # Duplicates the current mash as a new mash.
    def dup
      self.class.new(self, default)
    end

    alias_method :regular_key?, :key?
    def key?(key)
      super(convert_key(key))
    end
    alias_method :has_key?, :key?
    alias_method :include?, :key?
    alias_method :member?, :key?

    # Performs a deep_update on a duplicate of the
    # current mash.
    def deep_merge(other_hash, &blk)
      dup.deep_update(other_hash, &blk)
    end
    alias_method :merge, :deep_merge

    # Recursively merges this mash with the passed
    # in hash, merging each hash in the hierarchy.
    def deep_update(other_hash, &blk)
      other_hash.each_pair do |k, v|
        key = convert_key(k)
        if regular_reader(key).is_a?(Mash) && v.is_a?(::Hash)
          custom_reader(key).deep_update(v, &blk)
        else
          value = convert_value(v, true)
          value = convert_value(blk.call(key, self[k], value), true) if blk && self.key?(k)
          custom_writer(key, value, false)
        end
      end
      self
    end
    alias_method :deep_merge!, :deep_update
    alias_method :update, :deep_update
    alias_method :merge!, :update

    # Assigns a value to a key
    def assign_property(name, value)
      self[name] = value
    end

    # Performs a shallow_update on a duplicate of the current mash
    def shallow_merge(other_hash)
      dup.shallow_update(other_hash)
    end

    # Merges (non-recursively) the hash from the argument,
    # changing the receiving hash
    def shallow_update(other_hash)
      other_hash.each_pair do |k, v|
        regular_writer(convert_key(k), convert_value(v, true))
      end
      self
    end

    def replace(other_hash)
      (keys - other_hash.keys).each { |key| delete(key) }
      other_hash.each { |key, value| self[key] = value }
      self
    end

    def respond_to_missing?(method_name, *args)
      return true if key?(method_name)
      suffix = method_suffix(method_name)
      if suffix
        true
      else
        super
      end
    end

    def prefix_method?(method_name)
      method_name = method_name.to_s
      method_name.end_with?(*ALLOWED_SUFFIXES) && key?(method_name.chop)
    end

    def method_missing(method_name, *args, &blk)
      return self.[](method_name, &blk) if key?(method_name)
      name, suffix = method_name_and_suffix(method_name)
      case suffix
      when '='.freeze
        assign_property(name, args.first)
      when '?'.freeze
        !!self[name]
      when '!'.freeze
        initializing_reader(name)
      when '_'.freeze
        underbang_reader(name)
      else
        self[method_name]
      end
    end

    # play nice with ActiveSupport Array#extract_options!
    def extractable_options?
      true
    end

    # another ActiveSupport method, see issue #270
    def reverse_merge(other_hash)
      self.class.new(other_hash).merge(self)
    end

    with_minimum_ruby('2.3.0') do
      def dig(*keys)
        super(*keys.map { |key| convert_key(key) })
      end
    end

    protected

    def method_name_and_suffix(method_name)
      method_name = method_name.to_s
      if method_name.end_with?(*ALLOWED_SUFFIXES)
        [method_name[0..-2], method_name[-1]]
      else
        [method_name[0..-1], nil]
      end
    end

    def method_suffix(method_name)
      method_name = method_name.to_s
      method_name[-1] if method_name.end_with?(*ALLOWED_SUFFIXES)
    end

    def convert_key(key) #:nodoc:
      key.to_s
    end

    def convert_value(val, duping = false) #:nodoc:
      case val
      when self.class
        val.dup
      when Hash
        duping ? val.dup : val
      when ::Hash
        val = val.dup if duping
        self.class.new(val)
      when Array
        val.map { |e| convert_value(e) }
      when ::Array
        Array.new(val.map { |e| convert_value(e) })
      else
        val
      end
    end

    private

    def log_built_in_message(method_key)
      return if self.class.disable_warnings?

      method_information = Hashie::Utils.method_information(method(method_key))

      Hashie.logger.warn(
        'You are setting a key that conflicts with a built-in method ' \
        "#{self.class}##{method_key} #{method_information}. " \
        'This can cause unexpected behavior when accessing the key as a ' \
        'property. You can still access the key via the #[] method.'
      )
    end

    def log_collision?(method_key)
      respond_to?(method_key) && !self.class.disable_warnings? &&
        !(regular_key?(method_key) || regular_key?(method_key.to_s))
    end
  end
end
