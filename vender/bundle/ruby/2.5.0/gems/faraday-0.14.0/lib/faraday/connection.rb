module Faraday
  # Public: Connection objects manage the default properties and the middleware
  # stack for fulfilling an HTTP request.
  #
  # Examples
  #
  #   conn = Faraday::Connection.new 'http://sushi.com'
  #
  #   # GET http://sushi.com/nigiri
  #   conn.get 'nigiri'
  #   # => #<Faraday::Response>
  #
  class Connection
    # A Set of allowed HTTP verbs.
    METHODS = Set.new [:get, :post, :put, :delete, :head, :patch, :options]

    # Public: Returns a Hash of URI query unencoded key/value pairs.
    attr_reader :params

    # Public: Returns a Hash of unencoded HTTP header key/value pairs.
    attr_reader :headers

    # Public: Returns a URI with the prefix used for all requests from this
    # Connection.  This includes a default host name, scheme, port, and path.
    attr_reader :url_prefix

    # Public: Returns the Faraday::Builder for this Connection.
    attr_reader :builder

    # Public: Returns a Hash of the request options.
    attr_reader :options

    # Public: Returns a Hash of the SSL options.
    attr_reader :ssl

    # Public: Returns the parallel manager for this Connection.
    attr_reader :parallel_manager

    # Public: Sets the default parallel manager for this connection.
    attr_writer :default_parallel_manager

    # Public: Gets or Sets the Hash proxy options.
    # attr_reader :proxy

    # Public: Initializes a new Faraday::Connection.
    #
    # url     - URI or String base URL to use as a prefix for all
    #           requests (optional).
    # options - Hash or Faraday::ConnectionOptions.
    #           :url     - URI or String base URL (default: "http:/").
    #           :params  - Hash of URI query unencoded key/value pairs.
    #           :headers - Hash of unencoded HTTP header key/value pairs.
    #           :request - Hash of request options.
    #           :ssl     - Hash of SSL options.
    #           :proxy   - URI, String or Hash of HTTP proxy options
    #                     (default: "http_proxy" environment variable).
    #                     :uri      - URI or String
    #                     :user     - String (optional)
    #                     :password - String (optional)
    def initialize(url = nil, options = nil)
      options = ConnectionOptions.from(options)

      if url.is_a?(Hash) || url.is_a?(ConnectionOptions)
        options = options.merge(url)
        url     = options.url
      end

      @parallel_manager = nil
      @headers = Utils::Headers.new
      @params  = Utils::ParamsHash.new
      @options = options.request
      @ssl = options.ssl
      @default_parallel_manager = options.parallel_manager

      @builder = options.builder || begin
        # pass an empty block to Builder so it doesn't assume default middleware
        options.new_builder(block_given? ? Proc.new { |b| } : nil)
      end

      self.url_prefix = url || 'http:/'

      @params.update(options.params)   if options.params
      @headers.update(options.headers) if options.headers

      @manual_proxy = !!options.proxy
      @proxy = options.proxy ? ProxyOptions.from(options.proxy) : proxy_from_env(url)
      @temp_proxy = @proxy

      yield(self) if block_given?

      @headers[:user_agent] ||= "Faraday v#{VERSION}"
    end

    # Public: Sets the Hash of URI query unencoded key/value pairs.
    def params=(hash)
      @params.replace hash
    end

    # Public: Sets the Hash of unencoded HTTP header key/value pairs.
    def headers=(hash)
      @headers.replace hash
    end

    extend Forwardable

    def_delegators :builder, :build, :use, :request, :response, :adapter, :app

    # Public: Makes an HTTP request without a body.
    #
    # url     - The optional String base URL to use as a prefix for all
    #           requests.  Can also be the options Hash.
    # params  - Hash of URI query unencoded key/value pairs.
    # headers - Hash of unencoded HTTP header key/value pairs.
    #
    # Examples
    #
    #   conn.get '/items', {:page => 1}, :accept => 'application/json'
    #   conn.head '/items/1'
    #
    #   # ElasticSearch example sending a body with GET.
    #   conn.get '/twitter/tweet/_search' do |req|
    #     req.headers[:content_type] = 'application/json'
    #     req.params[:routing] = 'kimchy'
    #     req.body = JSON.generate(:query => {...})
    #   end
    #
    # Yields a Faraday::Request for further request customizations.
    # Returns a Faraday::Response.
    #
    # Signature
    #
    #   <verb>(url = nil, params = nil, headers = nil)
    #
    # verb - An HTTP verb: get, head, or delete.
    %w[get head delete].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(url = nil, params = nil, headers = nil)
          run_request(:#{method}, url, nil, headers) { |request|
            request.params.update(params) if params
            yield(request) if block_given?
          }
        end
      RUBY
    end

    # Public: Makes an HTTP request with a body.
    #
    # url     - The optional String base URL to use as a prefix for all
    #           requests.  Can also be the options Hash.
    # body    - The String body for the request.
    # headers - Hash of unencoded HTTP header key/value pairs.
    #
    # Examples
    #
    #   conn.post '/items', data, :content_type => 'application/json'
    #
    #   # Simple ElasticSearch indexing sample.
    #   conn.post '/twitter/tweet' do |req|
    #     req.headers[:content_type] = 'application/json'
    #     req.params[:routing] = 'kimchy'
    #     req.body = JSON.generate(:user => 'kimchy', ...)
    #   end
    #
    # Yields a Faraday::Request for further request customizations.
    # Returns a Faraday::Response.
    #
    # Signature
    #
    #   <verb>(url = nil, body = nil, headers = nil)
    #
    # verb - An HTTP verb: post, put, or patch.
    %w[post put patch].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(url = nil, body = nil, headers = nil, &block)
          run_request(:#{method}, url, body, headers, &block)
        end
      RUBY
    end

    # Public: Sets up the Authorization header with these credentials, encoded
    # with base64.
    #
    # login - The authentication login.
    # pass  - The authentication password.
    #
    # Examples
    #
    #   conn.basic_auth 'Aladdin', 'open sesame'
    #   conn.headers['Authorization']
    #   # => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
    #
    # Returns nothing.
    def basic_auth(login, pass)
      set_authorization_header(:basic_auth, login, pass)
    end

    # Public: Sets up the Authorization header with the given token.
    #
    # token   - The String token.
    # options - Optional Hash of extra token options.
    #
    # Examples
    #
    #   conn.token_auth 'abcdef', :foo => 'bar'
    #   conn.headers['Authorization']
    #   # => "Token token=\"abcdef\",
    #               foo=\"bar\""
    #
    # Returns nothing.
    def token_auth(token, options = nil)
      set_authorization_header(:token_auth, token, options)
    end

    # Public: Sets up a custom Authorization header.
    #
    # type  - The String authorization type.
    # token - The String or Hash token.  A String value is taken literally, and
    #         a Hash is encoded into comma separated key/value pairs.
    #
    # Examples
    #
    #   conn.authorization :Bearer, 'mF_9.B5f-4.1JqM'
    #   conn.headers['Authorization']
    #   # => "Bearer mF_9.B5f-4.1JqM"
    #
    #   conn.authorization :Token, :token => 'abcdef', :foo => 'bar'
    #   conn.headers['Authorization']
    #   # => "Token token=\"abcdef\",
    #               foo=\"bar\""
    #
    # Returns nothing.
    def authorization(type, token)
      set_authorization_header(:authorization, type, token)
    end

    # Internal: Traverse the middleware stack in search of a
    # parallel-capable adapter.
    #
    # Yields in case of not found.
    #
    # Returns a parallel manager or nil if not found.
    def default_parallel_manager
      @default_parallel_manager ||= begin
        handler = @builder.handlers.detect do |h|
          h.klass.respond_to?(:supports_parallel?) and h.klass.supports_parallel?
        end

        if handler
          handler.klass.setup_parallel_manager
        elsif block_given?
          yield
        end
      end
    end

    # Public: Determine if this Faraday::Connection can make parallel requests.
    #
    # Returns true or false.
    def in_parallel?
      !!@parallel_manager
    end

    # Public: Sets up the parallel manager to make a set of requests.
    #
    # manager - The parallel manager that this Connection's Adapter uses.
    #
    # Yields a block to execute multiple requests.
    # Returns nothing.
    def in_parallel(manager = nil)
      @parallel_manager = manager || default_parallel_manager {
        warn "Warning: `in_parallel` called but no parallel-capable adapter on Faraday stack"
        warn caller[2,10].join("\n")
        nil
      }
      yield
      @parallel_manager && @parallel_manager.run
    ensure
      @parallel_manager = nil
    end

    # Public: Gets or Sets the Hash proxy options.
    def proxy(arg = nil)
      return @proxy if arg.nil?
      warn 'Warning: use of proxy(new_value) to set connection proxy have been DEPRECATED and will be removed in Faraday 1.0'
      @manual_proxy = true
      @proxy = ProxyOptions.from(arg)
    end

    # Public: Sets the Hash proxy options.
    def proxy=(new_value)
      @manual_proxy = true
      @proxy = new_value ? ProxyOptions.from(new_value) : nil
    end

    def_delegators :url_prefix, :scheme, :scheme=, :host, :host=, :port, :port=
    def_delegator :url_prefix, :path, :path_prefix

    # Public: Parses the giving url with URI and stores the individual
    # components in this connection.  These components serve as defaults for
    # requests made by this connection.
    #
    # url - A String or URI.
    #
    # Examples
    #
    #   conn = Faraday::Connection.new { ... }
    #   conn.url_prefix = "https://sushi.com/api"
    #   conn.scheme      # => https
    #   conn.path_prefix # => "/api"
    #
    #   conn.get("nigiri?page=2") # accesses https://sushi.com/api/nigiri
    #
    # Returns the parsed URI from the given input..
    def url_prefix=(url, encoder = nil)
      uri = @url_prefix = Utils.URI(url)
      self.path_prefix = uri.path

      params.merge_query(uri.query, encoder)
      uri.query = nil

      with_uri_credentials(uri) do |user, password|
        basic_auth user, password
        uri.user = uri.password = nil
      end

      uri
    end

    # Public: Sets the path prefix and ensures that it always has a leading
    # slash.
    #
    # value - A String.
    #
    # Returns the new String path prefix.
    def path_prefix=(value)
      url_prefix.path = if value
        value = '/' + value unless value[0,1] == '/'
        value
      end
    end

    # Public: Takes a relative url for a request and combines it with the defaults
    # set on the connection instance.
    #
    #   conn = Faraday::Connection.new { ... }
    #   conn.url_prefix = "https://sushi.com/api?token=abc"
    #   conn.scheme      # => https
    #   conn.path_prefix # => "/api"
    #
    #   conn.build_url("nigiri?page=2")      # => https://sushi.com/api/nigiri?token=abc&page=2
    #   conn.build_url("nigiri", :page => 2) # => https://sushi.com/api/nigiri?token=abc&page=2
    #
    def build_url(url = nil, extra_params = nil)
      uri = build_exclusive_url(url)

      query_values = params.dup.merge_query(uri.query, options.params_encoder)
      query_values.update extra_params if extra_params
      uri.query = query_values.empty? ? nil : query_values.to_query(options.params_encoder)

      uri
    end

    # Builds and runs the Faraday::Request.
    #
    # method  - The Symbol HTTP method.
    # url     - The String or URI to access.
    # body    - The request body that will eventually be converted to a string.
    # headers - Hash of unencoded HTTP header key/value pairs.
    #
    # Returns a Faraday::Response.
    def run_request(method, url, body, headers)
      if !METHODS.include?(method)
        raise ArgumentError, "unknown http method: #{method}"
      end

      # Resets temp_proxy
      @temp_proxy = proxy_for_request(url)

      request = build_request(method) do |req|
        req.options = req.options.merge(:proxy => @temp_proxy)
        req.url(url)                if url
        req.headers.update(headers) if headers
        req.body = body             if body
        yield(req) if block_given?
      end

      builder.build_response(self, request)
    end

    # Creates and configures the request object.
    #
    # Returns the new Request.
    def build_request(method)
      Request.create(method) do |req|
        req.params  = self.params.dup
        req.headers = self.headers.dup
        req.options = self.options
        yield(req) if block_given?
      end
    end

    # Internal: Build an absolute URL based on url_prefix.
    #
    # url    - A String or URI-like object
    # params - A Faraday::Utils::ParamsHash to replace the query values
    #          of the resulting url (default: nil).
    #
    # Returns the resulting URI instance.
    def build_exclusive_url(url = nil, params = nil, params_encoder = nil)
      url = nil if url.respond_to?(:empty?) and url.empty?
      base = url_prefix
      if url and base.path and base.path !~ /\/$/
        base = base.dup
        base.path = base.path + '/'  # ensure trailing slash
      end
      uri = url ? base + url : base
      uri.query = params.to_query(params_encoder || options.params_encoder) if params
      uri.query = nil if uri.query and uri.query.empty?
      uri
    end

    # Internal: Creates a duplicate of this Faraday::Connection.
    #
    # Returns a Faraday::Connection.
    def dup
      self.class.new(build_exclusive_url,
                     :headers => headers.dup,
                     :params => params.dup,
                     :builder => builder.dup,
                     :ssl => ssl.dup,
                     :request => options.dup)
    end

    # Internal: Yields username and password extracted from a URI if they both exist.
    def with_uri_credentials(uri)
      if uri.user and uri.password
        yield(Utils.unescape(uri.user), Utils.unescape(uri.password))
      end
    end

    def set_authorization_header(header_type, *args)
      header = Faraday::Request.lookup_middleware(header_type).
        header(*args)
      headers[Faraday::Request::Authorization::KEY] = header
    end

    def proxy_from_env(url)
      return if Faraday.ignore_env_proxy
      uri = nil
      if URI.parse('').respond_to?(:find_proxy)
        case url
        when String
            uri = Utils.URI(url)
            uri = URI.parse("#{uri.scheme}://#{uri.hostname}").find_proxy
          when URI
            uri = url.find_proxy
          when nil
            uri = find_default_proxy
        end
      else
        warn 'no_proxy is unsupported' if ENV['no_proxy'] || ENV['NO_PROXY']
        uri = find_default_proxy
      end
      ProxyOptions.from(uri) if uri
    end

    def find_default_proxy
      uri = ENV['http_proxy']
      if uri && !uri.empty?
        uri = 'http://' + uri if uri !~ /^http/i
        uri
      end
    end

    def proxy_for_request(url)
      return self.proxy if @manual_proxy
      if url && Utils.URI(url).absolute?
        proxy_from_env(url)
      else
        self.proxy
      end
    end
  end
end
