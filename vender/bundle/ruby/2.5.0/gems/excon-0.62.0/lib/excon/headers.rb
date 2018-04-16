# frozen_string_literal: true
module Excon
  class Headers < Hash

    SENTINEL = {}

    alias_method :raw_writer, :[]=
    alias_method :raw_reader, :[]
    if SENTINEL.respond_to?(:assoc)
      alias_method :raw_assoc, :assoc
    end
    alias_method :raw_delete, :delete
    alias_method :raw_fetch, :fetch
    alias_method :raw_has_key?, :has_key?
    alias_method :raw_include?, :include?
    alias_method :raw_key?, :key?
    alias_method :raw_member?, :member?
    alias_method :raw_merge, :merge
    alias_method :raw_merge!, :merge!
    alias_method :raw_rehash, :rehash
    alias_method :raw_store, :store
    alias_method :raw_values_at, :values_at

    def initialize
      @downcased = {}
    end

    def [](key)
      @downcased[key.to_s.downcase]
    end

    alias_method :[]=, :store
    def []=(key, value)
      raw_writer(key, value)
      @downcased[key.to_s.downcase] = value
    end

    if SENTINEL.respond_to? :assoc
      def assoc(obj)
        @downcased.assoc(obj.downcase)
      end
    end

    def delete(key, &proc)
      raw_delete(key, &proc)
      @downcased.delete(key.to_s.downcase, &proc)
    end

    def fetch(key, default = nil, &proc)
      if proc
        @downcased.fetch(key.to_s.downcase, &proc)
      else
        @downcased.fetch(key.to_s.downcase, default)
      end
    end

    alias_method :has_key?, :key?
    alias_method :has_key?, :member?
    def has_key?(key)
      raw_key?(key) || @downcased.has_key?(key.to_s.downcase)
    end

    def merge(other_hash)
      self.dup.merge!(other_hash)
    end

    def merge!(other_hash)
      other_hash.each do |key, value|
        self[key] = value
      end
      raw_merge!(other_hash)
    end

    def rehash
      @downcased.rehash
      raw_rehash
    end

    def values_at(*keys)
      @downcased.values_at(*keys.map {|key| key.to_s.downcase})
    end

  end
end
