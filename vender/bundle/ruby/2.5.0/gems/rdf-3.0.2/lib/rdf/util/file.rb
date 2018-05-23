require 'net/http'
require 'link_header'
require 'time'
require 'openssl'

module RDF; module Util
  ##
  # Wrapper for retrieving RDF resources from HTTP(S) and file: scheme locations.
  # 
  # By default, HTTP(S) resources are retrieved using Net::HTTP. However, 
  # If the [Rest Client](https://rubygems.org/gems/rest-client) gem is included,
  # it will be used for retrieving resources, allowing for
  # sophisticated HTTP caching using [REST Client Components](https://rubygems.org/gems/rest-client-components)
  # allowing the use of `Rack::Cache` to avoid network access.
  #
  # To use other HTTP clients, consumers can subclass 
  # {RDF::Util::File::HttpAdapter} and set the {RDF::Util::File.http_adapter}.
  #
  # Also supports the file: scheme for access to local files.
  #
  #
  # @since 0.2.4
  module File

    ##
    # @abstract Subclass and override {.open_url} to implement a custom adapter
    # @since 1.2
    class HttpAdapter
      ##
      # @param [Array, String] headers
      #   HTTP Request headers
      # @return [Hash] A hash of HTTP request headers
      def self.headers headers: {}
        headers['Accept'] ||= default_accept_header
        headers
      end

      ##
      # @return [String] the value for an Accept header
      def self.default_accept_header
        (RDF::Format.accept_types + %w(*/*;q=0.1)).join(", ")
      end
      
      ##
      # @abstract
      # @param [String] base_uri to open
      # @param [String] proxy
      #   HTTP Proxy to use for requests.
      # @param [Array, String] headers ({})
      #   HTTP Request headers
      # @param [Boolean] verify_none (false)
      #   Don't verify SSL certificates
      # @param  [Hash{Symbol => Object}] options
      #   options are ignored in this implementation. Applications are encouraged
      #   to override this implementation to provide more control over HTTP
      #   headers and redirect following.
      # @return [RemoteDocument, Object] A {RemoteDocument}. If a block is given, the result of evaluating the block is returned.
      # @raise [IOError] if not found
      def self.open_url(base_uri, proxy: nil, headers: {}, verify_none: false, **options)
        raise NoMethodError.new("#{self.inspect} does not implement required method `open_url` for ", "open_url")
      end
    end

    ##
    # If the [Rest Client](https://rubygems.org/gems/rest-client) gem is included,
    # it will be used for retrieving resources allowing for
    # sophisticated HTTP caching using [REST Client Components](https://rubygems.org/gems/rest-client-components)
    # allowing the use of `Rack::Cache` to avoid network access.
    # @since 1.2
    class RestClientAdapter < HttpAdapter
      # (see HttpAdapter.open_url)
      def self.open_url(base_uri, proxy: nil, headers: {}, verify_none: false, **options)
        ssl_verify = verify_none ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER

        # If RestClient is loaded, prefer it
        RestClient.proxy = proxy.to_s if proxy
        client = RestClient::Resource.new(base_uri, verify_ssl: ssl_verify)
        client.get(headers(headers: headers)) do |response, request, res, &blk|
          case response.code
          when 200..299
            # found object

            # If a Location is returned, it defines the base resource for this file, not it's actual ending location
            document_options = {
              base_uri:     RDF::URI(response.headers.fetch(:location, base_uri)),
              code:         response.code.to_i,
              headers:      response.headers
            }

            remote_document = RemoteDocument.new(response.body, document_options)
          when 300..399
            # Document base is redirected location
            # Location may be relative
            base_uri = ::URI.join(base_uri, response.headers[:location].to_s).to_s
            response.follow_redirection(&blk)
          else
            raise IOError, "<#{base_uri}>: #{response.code}"
          end
        end
      end
    end

    ##
    # Net::HTTP adapter to retrieve resources without additional dependencies
    # @since 1.2
    class NetHttpAdapter < HttpAdapter
      # (see HttpAdapter.open_url)
      def self.open_url(base_uri, proxy: nil, headers: {}, verify_none: false, **options)
        ssl_verify = verify_none ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER

        redirect_count = 0
        max_redirects = 5
        parsed_url = ::URI.parse(base_uri)
        parsed_proxy = ::URI.parse(proxy.to_s)
        base_uri = parsed_url.to_s
        remote_document = nil

        until remote_document do
          Net::HTTP::start(parsed_url.host, parsed_url.port,
                          parsed_proxy.host, parsed_proxy.port,
                          open_timeout: 60 * 1000,
                          use_ssl: parsed_url.scheme == 'https',
                          verify_mode: ssl_verify
          ) do |http|
            request = Net::HTTP::Get.new(parsed_url.request_uri, headers(headers: headers))
            http.request(request) do |response|
              case response
              when Net::HTTPSuccess
                # found object

                # Normalize headers using symbols
                response_headers = response.to_hash.inject({}) do |out, (key, value)|
                  out[key.gsub(/-/, '_').downcase.to_sym] = %w{ set-cookie }.include?(key.downcase) ? value : value.first
                  out
                end

                # If a Location is returned, it defines the base resource for this file, not it's actual ending location
                document_options = {
                  base_uri:     RDF::URI(response["Location"] ? response["Location"] : base_uri),
                  code:         response.code.to_i,
                  content_type: response.content_type,
                  headers:      response_headers
                }.merge(response.type_params)
                document_options[:last_modified] = DateTime.parse(response["Last-Modified"]) if response["Last-Modified"]

                remote_document = RemoteDocument.new(response.body, document_options)
              when Net::HTTPRedirection
                # Follow redirection
                raise IOError, "Too many redirects" if (redirect_count += 1) > max_redirects

                # Location may be relative
                parsed_url = ::URI.join(base_uri, response["Location"])

                base_uri = parsed_url.to_s
              else
                raise IOError, "<#{parsed_url}>: #{response.message}(#{response.code})"
              end
            end
          end
        end
        remote_document
      end
    end

    ##
    # Use Faraday for retrieving resources
    # @since 1.2
    class FaradayAdapter < HttpAdapter
      class <<self
        ##
        # Set the Faraday::Connection to use for retrieving RDF resources
        def conn= conn
          @conn = conn
        end

        ##
        # Get the Faraday::Connection to use for retrieving RDF resources,
        # or a default connect that follows redirects.
        def conn
          @conn ||= Faraday.new do |conn|
            conn.use FaradayMiddleware::FollowRedirects
            conn.adapter Faraday.default_adapter
          end
        end
      end

      # (see HttpAdapter.open_url)
      def self.open_url(base_uri, proxy: nil, headers: {}, verify_none: false, **options)
        response = conn.get do |req|
          req.url base_uri
          headers(headers: headers).each do |k,v|
            req.headers[k] = v
          end
        end

        case response.status
        when 200..299
          # found object

          # If a Location is returned, it defines the base resource for this file, not it's actual ending location
          document_options = {
            base_uri:     RDF::URI(response.headers.fetch(:location, response.env.url)),
            code:         response.status,
            headers:      response.headers
          }

          remote_document = RemoteDocument.new(response.body, document_options)
        else
          raise IOError, "<#{base_uri}>: #{response.status}"
        end
      end
    end

    class << self
      ##
      # Set the HTTP adapter
      # @see .http_adapter
      # @param [HttpAdapter] http_adapter
      # @return [HttpAdapter]
      # @since 1.2
      def http_adapter= http_adapter
        @http_adapter = http_adapter
      end

      ##
      # Get current HTTP adapter. If no adapter has been explicitly set,
      # use RestClientAdapter (if RestClient is loaded), or the NetHttpAdapter
      #
      # @param [Boolean] use_net_http use the NetHttpAdapter, even if other
      #      adapters have been configured
      # @return [HttpAdapter]
      # @since 1.2
      def http_adapter(use_net_http = false)
        if use_net_http
          NetHttpAdapter
        else
          @http_adapter ||= begin
            # Otherwise, fallback to Net::HTTP
            if defined?(RestClient)
              RestClientAdapter
            else
              NetHttpAdapter
            end
          end
        end
      end
    end

    ##
    # Open the file, returning or yielding {RemoteDocument}.
    #
    # Adds Accept header based on available reader content types to allow
    # for content negotiation based on available readers.
    #
    # Input received as non-unicode, is transformed to UTF-8. With Ruby >= 2.2, all UTF is normalized to [Unicode Normalization Form C (NFC)](http://unicode.org/reports/tr15/#Norm_Forms).
    #
    # HTTP resources may be retrieved via proxy using the `proxy` option. If `RestClient` is loaded, they will use the proxy globally by setting something like the following:
    #     `RestClient.proxy = "http://proxy.example.com/"`.
    # When retrieving documents over HTTP(S), use the mechanism described in [Providing and Discovering URI Documentation](http://www.w3.org/2001/tag/awwsw/issue57/latest/) to pass the appropriate `base_uri` to the block or as the return.
    #
    # Applications needing HTTP caching may consider
    # [Rest Client](https://rubygems.org/gems/rest-client) and
    # [REST Client Components](https://rubygems.org/gems/rest-client-components)
    # allowing the use of `Rack::Cache` as a local file cache.
    #
    # @example using a local HTTP cache
    #    require 'restclient/components'
    #    require 'rack/cache'
    #    RestClient.enable Rack::Cache
    #    RDF::Util::File.open_file("http://example.org/some/resource")
    #      # => Cached resource if current, otherwise returned resource
    #
    # @param [String] filename_or_url to open
    # @param [String] proxy
    #   HTTP Proxy to use for requests.
    # @param [Array, String] headers ({})
    #   HTTP Request headers
    # @param [Boolean] verify_none (false)
    #   Don't verify SSL certificates
    # @param  [Hash{Symbol => Object}] options
    #   options are ignored in this implementation. Applications are encouraged
    #   to override this implementation to provide more control over HTTP
    #   headers and redirect following. If opening as a file,
    #   options are passed to `Kernel.open`.
    # @return [RemoteDocument, Object] A {RemoteDocument}. If a block is given, the result of evaluating the block is returned.
    # @yield [ RemoteDocument] A {RemoteDocument} for local files
    # @yieldreturn [Object] returned from open_file
    # @raise [IOError] if not found
    def self.open_file(filename_or_url, proxy: nil, headers: {}, verify_none: false, **options, &block)
      filename_or_url = $1 if filename_or_url.to_s.match(/^file:(.*)$/)
      remote_document = nil

      if filename_or_url.to_s =~ /^https?/
        base_uri = filename_or_url.to_s

        remote_document = self.http_adapter(!!options[:use_net_http]).
          open_url(base_uri,
                   proxy:       proxy,
                   headers:     headers,
                   verify_none: verify_none,
                   **options)
      else
        # Fake content type based on found format
        format = RDF::Format.for(filename_or_url.to_s)
        content_type = format ? format.content_type.first : 'text/plain'
        # Open as a file, passing any options
        begin
          url_no_frag_or_query = RDF::URI(filename_or_url).dup
          url_no_frag_or_query.query = nil
          url_no_frag_or_query.fragment = nil
          options[:encoding] ||= Encoding::UTF_8
          Kernel.open(url_no_frag_or_query, "r", options) do |file|
            document_options = {
              base_uri:     filename_or_url.to_s,
              charset:      file.external_encoding.to_s,
              code:         200,
              content_type: content_type,
              last_modified:file.mtime,
              headers:      {content_type: content_type, last_modified: file.mtime.xmlschema}
            }

            remote_document = RemoteDocument.new(file.read, document_options)
          end
        rescue Errno::ENOENT => e
          raise IOError, e.message
        end
      end

      if block_given?
        yield remote_document
      else
        remote_document
      end
    end

    ##
    # A RemoteDocument contains the body and headers of a remote resource.
    #
    # Link headers are parsed using the `LinkHeader` gem
    # @see https://github.com/asplake/link_header
    class RemoteDocument < StringIO
      # Base URI based on resource location or returned Location header.
      # @return [String]
      attr_reader :base_uri

      # Content-Type of the returned resource
      # @return [String]
      attr_reader :content_type

      # Encoding of resource (from Content-Type), downcased. Also applied to content if it is UTF
      # @return [String}]
      attr_reader :charset

      # Response code
      # @return [Integer]
      attr_reader :code

      ##
      # ETag from headers
      # @return [String]
      attr_reader :etag

      # Last-Modified time from headers
      # @return [DateTime]
      attr_reader :last_modified

      # Raw headers from response
      # @return [Hash{Symbol => Object}]
      attr_reader :headers

      # Originally requested URL
      # @return [String]
      attr_reader :requested_url

      ##
      # Set content
      # @param [String] body entity content of request.
      def initialize(body, options = {})
        options.each do |key, value|
          # de-quote charset
          matchdata = value.match(/^["'](.*)["']$/.freeze) if key == "charset"
          value = matchdata[1] if matchdata
          value = value.downcase if value.is_a?(String)
          instance_variable_set(:"@#{key}", value)
        end
        @headers = options.fetch(:headers, {})
        @charset = options[:charset].to_s.downcase if options[:charset]

        # Find Content-Type
        if headers[:content_type]
          ct, *params = headers[:content_type].split(';').map(&:strip)
          @content_type ||= ct

          # Find charset
          params.each do |param|
            p, v = param.split('=')
            next unless p.downcase == 'charset'
            @charset ||= v.sub(/^["']?(.*)["']?$/, '\1').downcase
          end
        end

        @etag = headers[:etag]
        @last_modified = DateTime.parse(headers[:last_modified]) if headers[:last_modified]
        encoding = @charset ||= "utf-8"

        unless encoding.start_with?("utf")
          body.force_encoding(Encoding::UTF_8)
          encoding = "utf-8"

          # Make sure Unicode is in NFC
          begin
            body.unicode_normalize! unless !body.unicode_normalized?
          rescue Encoding::CompatibilityError
            # Oh, well ...
          end if body.respond_to?(:unicode_normalized?)
        end

        super(body, "r:#{encoding}")
      end

      ##
      # Returns a list of encodings in Content-Encoding field as an array of strings.
      #
      # The encodings are downcased for canonicalization.
      # @return [Array<String>]
      def content_encoding
        headers.fetch(:content_encoding, "").split(',').map(&:strip).map(&:downcase)
      end

      ##
      # Return links from the Link header.
      #
      # Links can be returned in array form, or searched.
      #
      # @example
      #
      #     d = RemoteDocument.new(...)
      #     describedby = links.find_link(['rel', 'describedby']).href
      #
      # @return [::LinkHeader]
      def links
        @links ||= LinkHeader.parse(@headers[:link])
      end
    end
  end # File
end; end # RDF::Util
