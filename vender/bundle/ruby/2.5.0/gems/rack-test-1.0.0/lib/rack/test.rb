require 'uri'
require 'rack'
require 'rack/mock_session'
require 'rack/test/cookie_jar'
require 'rack/test/mock_digest_request'
require 'rack/test/utils'
require 'rack/test/methods'
require 'rack/test/uploaded_file'
require 'rack/test/version'

module Rack
  module Test
    DEFAULT_HOST = 'example.org'.freeze
    MULTIPART_BOUNDARY = '----------XnJLe9ZIbbGUYtzPQJ16u1'.freeze

    # The common base class for exceptions raised by Rack::Test
    class Error < StandardError; end

    # This class represents a series of requests issued to a Rack app, sharing
    # a single cookie jar
    #
    # Rack::Test::Session's methods are most often called through Rack::Test::Methods,
    # which will automatically build a session when it's first used.
    class Session
      extend Forwardable
      include Rack::Test::Utils

      def_delegators :@rack_mock_session, :clear_cookies, :set_cookie, :last_response, :last_request

      # Creates a Rack::Test::Session for a given Rack app or Rack::MockSession.
      #
      # Note: Generally, you won't need to initialize a Rack::Test::Session directly.
      # Instead, you should include Rack::Test::Methods into your testing context.
      # (See README.rdoc for an example)
      def initialize(mock_session)
        @headers = {}
        @env = {}
        @digest_username = nil
        @digest_password = nil

        @rack_mock_session = if mock_session.is_a?(MockSession)
          mock_session
        else
          MockSession.new(mock_session)
        end

        @default_host = @rack_mock_session.default_host
      end

      # Issue a GET request for the given URI with the given params and Rack
      # environment. Stores the issues request object in #last_request and
      # the app's response in #last_response. Yield #last_response to a block
      # if given.
      #
      # Example:
      #   get "/"
      def get(uri, params = {}, env = {}, &block)
        custom_request('GET', uri, params, env, &block)
      end

      # Issue a POST request for the given URI. See #get
      #
      # Example:
      #   post "/signup", "name" => "Bryan"
      def post(uri, params = {}, env = {}, &block)
        custom_request('POST', uri, params, env, &block)
      end

      # Issue a PUT request for the given URI. See #get
      #
      # Example:
      #   put "/"
      def put(uri, params = {}, env = {}, &block)
        custom_request('PUT', uri, params, env, &block)
      end

      # Issue a PATCH request for the given URI. See #get
      #
      # Example:
      #   patch "/"
      def patch(uri, params = {}, env = {}, &block)
        custom_request('PATCH', uri, params, env, &block)
      end

      # Issue a DELETE request for the given URI. See #get
      #
      # Example:
      #   delete "/"
      def delete(uri, params = {}, env = {}, &block)
        custom_request('DELETE', uri, params, env, &block)
      end

      # Issue an OPTIONS request for the given URI. See #get
      #
      # Example:
      #   options "/"
      def options(uri, params = {}, env = {}, &block)
        custom_request('OPTIONS', uri, params, env, &block)
      end

      # Issue a HEAD request for the given URI. See #get
      #
      # Example:
      #   head "/"
      def head(uri, params = {}, env = {}, &block)
        custom_request('HEAD', uri, params, env, &block)
      end

      # Issue a request to the Rack app for the given URI and optional Rack
      # environment. Stores the issues request object in #last_request and
      # the app's response in #last_response. Yield #last_response to a block
      # if given.
      #
      # Example:
      #   request "/"
      def request(uri, env = {}, &block)
        uri = parse_uri(uri, env)
        env = env_for(uri, env)
        process_request(uri, env, &block)
      end

      # Issue a request using the given verb for the given URI. See #get
      #
      # Example:
      #   custom_request "LINK", "/"
      def custom_request(verb, uri, params = {}, env = {}, &block)
        uri = parse_uri(uri, env)
        env = env_for(uri, env.merge(method: verb.to_s.upcase, params: params))
        process_request(uri, env, &block)
      end

      # Set a header to be included on all subsequent requests through the
      # session. Use a value of nil to remove a previously configured header.
      #
      # In accordance with the Rack spec, headers will be included in the Rack
      # environment hash in HTTP_USER_AGENT form.
      #
      # Example:
      #   header "User-Agent", "Firefox"
      def header(name, value)
        if value.nil?
          @headers.delete(name)
        else
          @headers[name] = value
        end
      end

      # Set an env var to be included on all subsequent requests through the
      # session. Use a value of nil to remove a previously configured env.
      #
      # Example:
      #   env "rack.session", {:csrf => 'token'}
      def env(name, value)
        if value.nil?
          @env.delete(name)
        else
          @env[name] = value
        end
      end

      # Set the username and password for HTTP Basic authorization, to be
      # included in subsequent requests in the HTTP_AUTHORIZATION header.
      #
      # Example:
      #   basic_authorize "bryan", "secret"
      def basic_authorize(username, password)
        encoded_login = ["#{username}:#{password}"].pack('m0')
        header('Authorization', "Basic #{encoded_login}")
      end

      alias authorize basic_authorize

      # Set the username and password for HTTP Digest authorization, to be
      # included in subsequent requests in the HTTP_AUTHORIZATION header.
      #
      # Example:
      #   digest_authorize "bryan", "secret"
      def digest_authorize(username, password)
        @digest_username = username
        @digest_password = password
      end

      # Rack::Test will not follow any redirects automatically. This method
      # will follow the redirect returned (including setting the Referer header
      # on the new request) in the last response. If the last response was not
      # a redirect, an error will be raised.
      def follow_redirect!
        unless last_response.redirect?
          raise Error, 'Last response was not a redirect. Cannot follow_redirect!'
        end
        request_method, params =
          if last_response.status == 307
            [last_request.request_method.downcase.to_sym, last_request.params]
          else
            [:get, {}]
          end
        send(
          request_method, last_response['Location'], params,
          'HTTP_REFERER' => last_request.url,
          'rack.session' => last_request.session
        )
      end

      private

      def parse_uri(path, env)
        URI.parse(path).tap do |uri|
          uri.path = "/#{uri.path}" unless uri.path[0] == '/'
          uri.host ||= @default_host
          uri.scheme ||= 'https' if env['HTTPS'] == 'on'
        end
      end

      def env_for(uri, env)
        env = default_env.merge(env)

        env['HTTP_HOST'] ||= [uri.host, (uri.port if uri.port != uri.default_port)].compact.join(':')

        env.update('HTTPS' => 'on') if URI::HTTPS === uri
        env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if env[:xhr]

        # TODO: Remove this after Rack 1.1 has been released.
        # Stringifying and upcasing methods has be commit upstream
        env['REQUEST_METHOD'] ||= env[:method] ? env[:method].to_s.upcase : 'GET'

        params = env.delete(:params) do {} end

        if env['REQUEST_METHOD'] == 'GET'
          # merge :params with the query string
          if params
            params = parse_nested_query(params) if params.is_a?(String)

            uri.query = [uri.query, build_nested_query(params)].compact.reject { |v| v == '' }.join('&')
          end
        elsif !env.key?(:input)
          env['CONTENT_TYPE'] ||= 'application/x-www-form-urlencoded'

          if params.is_a?(Hash)
            if data = build_multipart(params)
              env[:input] = data
              env['CONTENT_LENGTH'] ||= data.length.to_s
              env['CONTENT_TYPE'] = "multipart/form-data; boundary=#{MULTIPART_BOUNDARY}"
            else
              # NB: We do not need to set CONTENT_LENGTH here;
              # Rack::ContentLength will determine it automatically.
              env[:input] = params_to_string(params)
            end
          else
            env[:input] = params
          end
        end

        set_cookie(env.delete(:cookie), uri) if env.key?(:cookie)

        Rack::MockRequest.env_for(uri.to_s, env)
      end

      def process_request(uri, env)
        @rack_mock_session.request(uri, env)

        if retry_with_digest_auth?(env)
          auth_env = env.merge('HTTP_AUTHORIZATION' => digest_auth_header,
                               'rack-test.digest_auth_retry' => true)
          auth_env.delete('rack.request')
          process_request(uri.path, auth_env)
        else
          yield last_response if block_given?

          last_response
        end
      end

      def digest_auth_header
        challenge = last_response['WWW-Authenticate'].split(' ', 2).last
        params = Rack::Auth::Digest::Params.parse(challenge)

        params.merge!('username' => @digest_username,
                      'nc'        => '00000001',
                      'cnonce'    => 'nonsensenonce',
                      'uri'       => last_request.fullpath,
                      'method'    => last_request.env['REQUEST_METHOD'])

        params['response'] = MockDigestRequest.new(params).response(@digest_password)

        "Digest #{params}"
      end

      def retry_with_digest_auth?(env)
        last_response.status == 401 &&
          digest_auth_configured? &&
          !env['rack-test.digest_auth_retry']
      end

      def digest_auth_configured?
        @digest_username
      end

      def default_env
        { 'rack.test' => true, 'REMOTE_ADDR' => '127.0.0.1' }.merge(@env).merge(headers_for_env)
      end

      def headers_for_env
        converted_headers = {}

        @headers.each do |name, value|
          env_key = name.upcase.tr('-', '_')
          env_key = 'HTTP_' + env_key unless env_key == 'CONTENT_TYPE'
          converted_headers[env_key] = value
        end

        converted_headers
      end

      def params_to_string(params)
        case params
        when Hash then build_nested_query(params)
        when nil  then ''
        else params
        end
      end
    end

    def self.encoding_aware_strings?
      defined?(Encoding) && ''.respond_to?(:encode)
    end
  end
end
