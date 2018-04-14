module Faraday
  # Used to setup urls, params, headers, and the request body in a sane manner.
  #
  #   @connection.post do |req|
  #     req.url 'http://localhost', 'a' => '1' # 'http://localhost?a=1'
  #     req.headers['b'] = '2' # Header
  #     req.params['c']  = '3' # GET Param
  #     req['b']         = '2' # also Header
  #     req.body = 'abc'
  #   end
  #
  class Request < Struct.new(:method, :path, :params, :headers, :body, :options)
    extend MiddlewareRegistry

    register_middleware File.expand_path('../request', __FILE__),
      :url_encoded => [:UrlEncoded, 'url_encoded'],
      :multipart => [:Multipart, 'multipart'],
      :retry => [:Retry, 'retry'],
      :authorization => [:Authorization, 'authorization'],
      :basic_auth => [:BasicAuthentication, 'basic_authentication'],
      :token_auth => [:TokenAuthentication, 'token_authentication'],
      :instrumentation => [:Instrumentation, 'instrumentation']

    def self.create(request_method)
      new(request_method).tap do |request|
        yield(request) if block_given?
      end
    end

    # Public: Replace params, preserving the existing hash type
    def params=(hash)
      if params
        params.replace hash
      else
        super
      end
    end

    # Public: Replace request headers, preserving the existing hash type
    def headers=(hash)
      if headers
        headers.replace hash
      else
        super
      end
    end

    def url(path, params = nil)
      if path.respond_to? :query
        if query = path.query
          path = path.dup
          path.query = nil
        end
      else
        anchor_index = path.index('#')
        path = path.slice(0, anchor_index) unless anchor_index.nil?
        path, query = path.split('?', 2)
      end
      self.path = path
      self.params.merge_query query, options.params_encoder
      self.params.update(params) if params
    end

    def [](key)
      headers[key]
    end

    def []=(key, value)
      headers[key] = value
    end

    # ENV Keys
    # :method - a symbolized request method (:get, :post)
    # :body   - the request body that will eventually be converted to a string.
    # :url    - URI instance for the current request.
    # :status           - HTTP response status code
    # :request_headers  - hash of HTTP Headers to be sent to the server
    # :response_headers - Hash of HTTP headers from the server
    # :parallel_manager - sent if the connection is in parallel mode
    # :request - Hash of options for configuring the request.
    #   :timeout      - open/read timeout Integer in seconds
    #   :open_timeout - read timeout Integer in seconds
    #   :proxy        - Hash of proxy options
    #     :uri        - Proxy Server URI
    #     :user       - Proxy server username
    #     :password   - Proxy server password
    # :ssl - Hash of options for configuring SSL requests.
    def to_env(connection)
      Env.new(method, body, connection.build_exclusive_url(path, params),
        options, headers, connection.ssl, connection.parallel_manager)
    end
  end
end

