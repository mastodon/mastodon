# frozen_string_literal: true

require "addressable/uri"

module HTTP
  class URI
    extend Forwardable

    def_delegators :@uri, :scheme, :normalized_scheme, :scheme=
    def_delegators :@uri, :user, :normalized_user, :user=
    def_delegators :@uri, :password, :normalized_password, :password=
    def_delegators :@uri, :host, :normalized_host, :host=
    def_delegators :@uri, :authority, :normalized_authority, :authority=
    def_delegators :@uri, :origin, :origin=
    def_delegators :@uri, :normalized_port, :port=
    def_delegators :@uri, :path, :normalized_path, :path=
    def_delegators :@uri, :query, :normalized_query, :query=
    def_delegators :@uri, :request_uri, :request_uri=
    def_delegators :@uri, :fragment, :normalized_fragment, :fragment=
    def_delegators :@uri, :omit, :join, :normalize

    # @private
    HTTP_SCHEME = "http"

    # @private
    HTTPS_SCHEME = "https"

    # Parse the given URI string, returning an HTTP::URI object
    #
    # @param [HTTP::URI, String, #to_str] uri to parse
    #
    # @return [HTTP::URI] new URI instance
    def self.parse(uri)
      return uri if uri.is_a?(self)

      new(Addressable::URI.parse(uri))
    end

    # Encodes key/value pairs as application/x-www-form-urlencoded
    #
    # @param [#to_hash, #to_ary] form_values to encode
    # @param [TrueClass, FalseClass] sort should key/value pairs be sorted first?
    #
    # @return [String] encoded value
    def self.form_encode(form_values, sort = false)
      Addressable::URI.form_encode(form_values, sort)
    end

    # Creates an HTTP::URI instance from the given options
    #
    # @param [Hash, Addressable::URI] options_or_uri
    #
    # @option options_or_uri [String, #to_str] :scheme URI scheme
    # @option options_or_uri [String, #to_str] :user for basic authentication
    # @option options_or_uri [String, #to_str] :password for basic authentication
    # @option options_or_uri [String, #to_str] :host name component
    # @option options_or_uri [String, #to_str] :port network port to connect to
    # @option options_or_uri [String, #to_str] :path component to request
    # @option options_or_uri [String, #to_str] :query component distinct from path
    # @option options_or_uri [String, #to_str] :fragment component at the end of the URI
    #
    # @return [HTTP::URI] new URI instance
    def initialize(options_or_uri = {})
      case options_or_uri
      when Hash
        @uri = Addressable::URI.new(options_or_uri)
      when Addressable::URI
        @uri = options_or_uri
      else
        raise TypeError, "expected Hash for options, got #{options_or_uri.class}"
      end
    end

    # Are these URI objects equal? Normalizes both URIs prior to comparison
    #
    # @param [Object] other URI to compare this one with
    #
    # @return [TrueClass, FalseClass] are the URIs equivalent (after normalization)?
    def ==(other)
      other.is_a?(URI) && normalize.to_s == other.normalize.to_s
    end

    # Are these URI objects equal? Does NOT normalizes both URIs prior to comparison
    #
    # @param [Object] other URI to compare this one with
    #
    # @return [TrueClass, FalseClass] are the URIs equivalent?
    def eql?(other)
      other.is_a?(URI) && to_s == other.to_s
    end

    # Hash value based off the normalized form of a URI
    #
    # @return [Integer] A hash of the URI
    def hash
      @hash ||= to_s.hash * -1
    end

    # Port number, either as specified or the default if unspecified
    #
    # @return [Integer] port number
    def port
      @uri.port || @uri.default_port
    end

    # @return [True] if URI is HTTP
    # @return [False] otherwise
    def http?
      HTTP_SCHEME == scheme
    end

    # @return [True] if URI is HTTPS
    # @return [False] otherwise
    def https?
      HTTPS_SCHEME == scheme
    end

    # @return [Object] duplicated URI
    def dup
      self.class.new @uri.dup
    end

    # Convert an HTTP::URI to a String
    #
    # @return [String] URI serialized as a String
    def to_s
      @uri.to_s
    end
    alias to_str to_s

    # @return [String] human-readable representation of URI
    def inspect
      format("#<%s:0x%014x URI:%s>", self.class.name, object_id << 1, to_s)
    end
  end
end
