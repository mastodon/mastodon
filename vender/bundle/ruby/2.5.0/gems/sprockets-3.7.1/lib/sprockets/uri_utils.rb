require 'uri'

module Sprockets
  # Internal: Asset URI related parsing utilities. Mixed into Environment.
  #
  # An Asset URI identifies the compiled Asset result. It shares the file:
  # scheme and requires an absolute path.
  #
  # Other query parameters
  #
  # type - String output content type. Otherwise assumed from file extension.
  #        This maybe different than the extension if the asset is transformed
  #        from one content type to another. For an example .coffee -> .js.
  #
  # id - Unique fingerprint of the entire asset and all its metadata. Assets
  #      will only have the same id if they serialize to an identical value.
  #
  # pipeline - String name of pipeline.
  #
  module URIUtils
    extend self

    # Internal: Parse URI into component parts.
    #
    # uri - String uri
    #
    # Returns Array of components.
    def split_uri(uri)
      URI.split(uri)
    end

    # Internal: Join URI component parts into String.
    #
    # Returns String.
    def join_uri(scheme, userinfo, host, port, registry, path, opaque, query, fragment)
      URI::Generic.new(scheme, userinfo, host, port, registry, path, opaque, query, fragment).to_s
    end

    # Internal: Parse file: URI into component parts.
    #
    # uri - String uri
    #
    # Returns [scheme, host, path, query].
    def split_file_uri(uri)
      scheme, _, host, _, _, path, _, query, _ = URI.split(uri)

      path = URI::Generic::DEFAULT_PARSER.unescape(path)
      path.force_encoding(Encoding::UTF_8)

      # Hack for parsing Windows "file:///C:/Users/IEUser" paths
      path.gsub!(/^\/([a-zA-Z]:)/, '\1'.freeze)

      [scheme, host, path, query]
    end

    # Internal: Join file: URI component parts into String.
    #
    # Returns String.
    def join_file_uri(scheme, host, path, query)
      str = "#{scheme}://"
      str << host if host
      path = "/#{path}" unless path.start_with?("/")
      str << URI::Generic::DEFAULT_PARSER.escape(path)
      str << "?#{query}" if query
      str
    end

    # Internal: Check if String is a valid Asset URI.
    #
    # str - Possible String asset URI.
    #
    # Returns true or false.
    def valid_asset_uri?(str)
      # Quick prefix check before attempting a full parse
      str.start_with?("file://") && parse_asset_uri(str) ? true : false
    rescue URI::InvalidURIError
      false
    end

    # Internal: Parse Asset URI.
    #
    # Examples
    #
    #   parse("file:///tmp/js/application.coffee?type=application/javascript")
    #   # => "/tmp/js/application.coffee", {type: "application/javascript"}
    #
    # uri - String asset URI
    #
    # Returns String path and Hash of symbolized parameters.
    def parse_asset_uri(uri)
      scheme, _, path, query = split_file_uri(uri)

      unless scheme == 'file'
        raise URI::InvalidURIError, "expected file:// scheme: #{uri}"
      end

      return path, parse_uri_query_params(query)
    end

    # Internal: Build Asset URI.
    #
    # Examples
    #
    #   build("/tmp/js/application.coffee", type: "application/javascript")
    #   # => "file:///tmp/js/application.coffee?type=application/javascript"
    #
    # path   - String file path
    # params - Hash of optional parameters
    #
    # Returns String URI.
    def build_asset_uri(path, params = {})
      join_file_uri("file", nil, path, encode_uri_query_params(params))
    end

    # Internal: Parse file-digest dependency URI.
    #
    # Examples
    #
    #   parse("file-digest:/tmp/js/application.js")
    #   # => "/tmp/js/application.js"
    #
    # uri - String file-digest URI
    #
    # Returns String path.
    def parse_file_digest_uri(uri)
      scheme, _, path, _ = split_file_uri(uri)

      unless scheme == 'file-digest'.freeze
        raise URI::InvalidURIError, "expected file-digest scheme: #{uri}"
      end

      path
    end

    # Internal: Build file-digest dependency URI.
    #
    # Examples
    #
    #   build("/tmp/js/application.js")
    #   # => "file-digest:/tmp/js/application.js"
    #
    # path - String file path
    #
    # Returns String URI.
    def build_file_digest_uri(path)
      join_file_uri('file-digest'.freeze, nil, path, nil)
    end

    # Internal: Serialize hash of params into query string.
    #
    # params - Hash of params to serialize
    #
    # Returns String query or nil if empty.
    def encode_uri_query_params(params)
      query = []

      params.each do |key, value|
        case value
        when Integer
          query << "#{key}=#{value}"
        when String, Symbol
          query << "#{key}=#{URI::Generic::DEFAULT_PARSER.escape(value.to_s)}"
        when TrueClass
          query << "#{key}"
        when FalseClass, NilClass
        else
          raise TypeError, "unexpected type: #{value.class}"
        end
      end

      "#{query.join('&')}" if query.any?
    end

    # Internal: Parse query string into hash of params
    #
    # query - String query string
    #
    # Return Hash of params.
    def parse_uri_query_params(query)
      query.to_s.split('&').reduce({}) do |h, p|
        k, v = p.split('=', 2)
        v = URI::Generic::DEFAULT_PARSER.unescape(v) if v
        h[k.to_sym] = v || true
        h
      end
    end
  end
end
