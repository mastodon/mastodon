# frozen_string_literal: true

require "forwardable"

require "http/errors"
require "http/headers/mixin"
require "http/headers/known"

module HTTP
  # HTTP Headers container.
  class Headers
    extend Forwardable
    include Enumerable

    # Matches HTTP header names when in "Canonical-Http-Format"
    CANONICAL_NAME_RE = /^[A-Z][a-z]*(?:-[A-Z][a-z]*)*$/

    # Matches valid header field name according to RFC.
    # @see http://tools.ietf.org/html/rfc7230#section-3.2
    COMPLIANT_NAME_RE = /^[A-Za-z0-9!#\$%&'*+\-.^_`|~]+$/

    # Class constructor.
    def initialize
      @pile = []
    end

    # Sets header.
    #
    # @param (see #add)
    # @return [void]
    def set(name, value)
      delete(name)
      add(name, value)
    end
    alias []= set

    # Removes header.
    #
    # @param [#to_s] name header name
    # @return [void]
    def delete(name)
      name = normalize_header name.to_s
      @pile.delete_if { |k, _| k == name }
    end

    # Appends header.
    #
    # @param [#to_s] name header name
    # @param [Array<#to_s>, #to_s] value header value(s) to be appended
    # @return [void]
    def add(name, value)
      name = normalize_header name.to_s
      Array(value).each { |v| @pile << [name, v.to_s] }
    end

    # Returns list of header values if any.
    #
    # @return [Array<String>]
    def get(name)
      name = normalize_header name.to_s
      @pile.select { |k, _| k == name }.map { |_, v| v }
    end

    # Smart version of {#get}.
    #
    # @return [nil] if header was not set
    # @return [String] if header has exactly one value
    # @return [Array<String>] if header has more than one value
    def [](name)
      values = get(name)

      case values.count
      when 0 then nil
      when 1 then values.first
      else        values
      end
    end

    # Tells whenever header with given `name` is set or not.
    #
    # @return [Boolean]
    def include?(name)
      name = normalize_header name.to_s
      @pile.any? { |k, _| k == name }
    end

    # Returns Rack-compatible headers Hash
    #
    # @return [Hash]
    def to_h
      Hash[keys.map { |k| [k, self[k]] }]
    end
    alias to_hash to_h

    # Returns headers key/value pairs.
    #
    # @return [Array<[String, String]>]
    def to_a
      @pile.map { |pair| pair.map(&:dup) }
    end

    # Returns human-readable representation of `self` instance.
    #
    # @return [String]
    def inspect
      "#<#{self.class} #{to_h.inspect}>"
    end

    # Returns list of header names.
    #
    # @return [Array<String>]
    def keys
      @pile.map { |k, _| k }.uniq
    end

    # Compares headers to another Headers or Array of key/value pairs
    #
    # @return [Boolean]
    def ==(other)
      return false unless other.respond_to? :to_a
      @pile == other.to_a
    end

    # Calls the given block once for each key/value pair in headers container.
    #
    # @return [Enumerator] if no block given
    # @return [Headers] self-reference
    def each
      return to_enum(__method__) unless block_given?
      @pile.each { |arr| yield(arr) }
      self
    end

    # @!method empty?
    #   Returns `true` if `self` has no key/value pairs
    #
    #   @return [Boolean]
    def_delegator :@pile, :empty?

    # @!method hash
    #   Compute a hash-code for this headers container.
    #   Two conatiners with the same content will have the same hash code.
    #
    #   @see http://www.ruby-doc.org/core/Object.html#method-i-hash
    #   @return [Fixnum]
    def_delegator :@pile, :hash

    # Properly clones internal key/value storage.
    #
    # @api private
    def initialize_copy(orig)
      super
      @pile = to_a
    end

    # Merges `other` headers into `self`.
    #
    # @see #merge
    # @return [void]
    def merge!(other)
      self.class.coerce(other).to_h.each { |name, values| set name, values }
    end

    # Returns new instance with `other` headers merged in.
    #
    # @see #merge!
    # @return [Headers]
    def merge(other)
      dup.tap { |dupped| dupped.merge! other }
    end

    class << self
      # Coerces given `object` into Headers.
      #
      # @raise [Error] if object can't be coerced
      # @param [#to_hash, #to_h, #to_a] object
      # @return [Headers]
      def coerce(object)
        unless object.is_a? self
          object = case
                   when object.respond_to?(:to_hash) then object.to_hash
                   when object.respond_to?(:to_h)    then object.to_h
                   when object.respond_to?(:to_a)    then object.to_a
                   else raise Error, "Can't coerce #{object.inspect} to Headers"
                   end
        end

        headers = new
        object.each { |k, v| headers.add k, v }
        headers
      end
      alias [] coerce
    end

    private

    # Transforms `name` to canonical HTTP header capitalization
    #
    # @param [String] name
    # @raise [HeaderError] if normalized name does not
    #   match {HEADER_NAME_RE}
    # @return [String] canonical HTTP header name
    def normalize_header(name)
      return name if name =~ CANONICAL_NAME_RE

      normalized = name.split(/[\-_]/).each(&:capitalize!).join("-")

      return normalized if normalized =~ COMPLIANT_NAME_RE

      raise HeaderError, "Invalid HTTP header field name: #{name.inspect}"
    end
  end
end
