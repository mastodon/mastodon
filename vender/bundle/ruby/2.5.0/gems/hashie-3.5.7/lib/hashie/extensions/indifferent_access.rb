module Hashie
  module Extensions
    # IndifferentAccess gives you the ability to not care
    # whether your hash has string or symbol keys. Made famous
    # in Rails for accessing query and POST parameters, this
    # is a handy tool for making sure your hash has maximum
    # utility.
    #
    # One unique feature of this mixin is that it will recursively
    # inject itself into sub-hash instances without modifying
    # the actual class of the sub-hash.
    #
    # @example
    #   class MyHash < Hash
    #     include Hashie::Extensions::MergeInitializer
    #     include Hashie::Extensions::IndifferentAccess
    #   end
    #
    #   h = MyHash.new(:foo => 'bar', 'baz' => 'blip')
    #   h['foo'] # => 'bar'
    #   h[:foo]  # => 'bar'
    #   h[:baz]  # => 'blip'
    #   h['baz'] # => 'blip'
    #
    module IndifferentAccess
      def self.included(base)
        Hashie::Extensions::Dash::IndifferentAccess::ClassMethods.tap do |extension|
          base.extend(extension) if base <= Hashie::Dash && !base.singleton_class.included_modules.include?(extension)
        end

        base.class_eval do
          alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
          alias_method :[]=, :indifferent_writer
          alias_method :store, :indifferent_writer
          %w(default update replace fetch delete key? values_at).each do |m|
            alias_method "regular_#{m}", m unless method_defined?("regular_#{m}")
            alias_method m, "indifferent_#{m}"
          end

          %w(include? member? has_key?).each do |key_alias|
            alias_method key_alias, :indifferent_key?
          end

          class << self
            def [](*)
              super.convert!
            end

            def try_convert(*)
              (hash = super) && self[hash]
            end
          end
        end
      end

      # This will inject indifferent access into an instance of
      # a hash without modifying the actual class. This is what
      # allows IndifferentAccess to spread to sub-hashes.
      def self.inject!(hash)
        (class << hash; self; end).send :include, IndifferentAccess
        hash.convert!
      end

      # Injects indifferent access into a duplicate of the hash
      # provided. See #inject!
      def self.inject(hash)
        inject!(hash.dup)
      end

      def convert_key(key)
        key.to_s
      end

      # Iterates through the keys and values, reconverting them to
      # their proper indifferent state. Used when IndifferentAccess
      # is injecting itself into member hashes.
      def convert!
        keys.each do |k|
          regular_writer convert_key(k), indifferent_value(regular_delete(k))
        end
        self
      end

      def indifferent_value(value)
        if hash_lacking_indifference?(value)
          IndifferentAccess.inject!(value)
        elsif value.is_a?(::Array)
          value.replace(value.map { |e| indifferent_value(e) })
        else
          value
        end
      end

      def indifferent_default(key = nil)
        return self[convert_key(key)] if key?(key)
        regular_default(key)
      end

      def indifferent_update(other_hash)
        return regular_update(other_hash) if hash_with_indifference?(other_hash)
        other_hash.each_pair do |k, v|
          self[k] = v
        end
      end

      def indifferent_writer(key, value)
        regular_writer convert_key(key), indifferent_value(value)
      end

      def indifferent_fetch(key, *args, &block)
        regular_fetch convert_key(key), *args, &block
      end

      def indifferent_delete(key)
        regular_delete convert_key(key)
      end

      def indifferent_key?(key)
        regular_key? convert_key(key)
      end

      def indifferent_values_at(*indices)
        indices.map { |i| self[i] }
      end

      def indifferent_access?
        true
      end

      def indifferent_replace(other_hash)
        (keys - other_hash.keys).each { |key| delete(key) }
        other_hash.each { |key, value| self[key] = value }
        self
      end

      def merge(*)
        super.convert!
      end

      def merge!(*)
        super.convert!
      end

      protected

      def hash_lacking_indifference?(other)
        other.is_a?(::Hash) &&
          !(other.respond_to?(:indifferent_access?) &&
            other.indifferent_access?)
      end

      def hash_with_indifference?(other)
        other.is_a?(::Hash) &&
          other.respond_to?(:indifferent_access?) &&
          other.indifferent_access?
      end
    end
  end
end
