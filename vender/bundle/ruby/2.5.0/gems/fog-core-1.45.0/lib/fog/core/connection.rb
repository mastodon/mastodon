module Fog
  module Core
    # Fog::Core::Connection is a generic class to contain a HTTP link to an API.
    #
    # It is intended to be subclassed by providers who can then add their own
    # modifications such as authentication or response object.
    #
    class Connection

      class << self
        @@user_agents = []

        def add_user_agent(str)
          if /\S+\/[\d|.]+/.match(str)
            @@user_agents << str
          else
            raise "User Agent must be in <app name>/<app version> notation."
          end
        end

        def user_agents
          agents = @@user_agents.dup
          agents << "fog/#{Fog::VERSION}" if defined?(Fog::VERSION)
          agents << "fog-core/#{Fog::Core::VERSION}"
          agents.uniq.compact.join(" ")
        end
      end

      # Prepares the connection and sets defaults for any future requests.
      #
      # @param [String] url The destination URL
      # @param persistent [Boolean]
      # @param [Hash] params
      # @option params [String] :body Default text to be sent over a socket. Only used if :body absent in Connection#request params
      # @option params [Hash<Symbol, String>] :headers The default headers to supply in a request. Only used if params[:headers] is not supplied to Connection#request
      # @option params [String] :host The destination host's reachable DNS name or IP, in the form of a String
      # @option params [String] :path Default path; appears after 'scheme://host:port/'. Only used if params[:path] is not supplied to Connection#request
      # @option params [String] :path_prefix Sticky version of the "path" arg. :XSpath_prefix => "foo/bar" with a request with :path => "blech" sends a request to path "foo/bar/blech"
      # @option params [Fixnum] :port The port on which to connect, to the destination host
      # @option params [Hash]   :query Default query; appended to the 'scheme://host:port/path/' in the form of '?key=value'. Will only be used if params[:query] is not supplied to Connection#request
      # @option params [String] :scheme The protocol; 'https' causes OpenSSL to be used
      # @option params [String] :proxy Proxy server; e.g. 'http://myproxy.com:8888'
      # @option params [Fixnum] :retry_limit Set how many times we'll retry a failed request.  (Default 4)
      # @option params [Class] :instrumentor Responds to #instrument as in ActiveSupport::Notifications
      # @option params [String] :instrumentor_name Name prefix for #instrument events.  Defaults to 'excon'
      def initialize(url, persistent = false, params = {})
        if params[:path_prefix]
          if params[:path]
            raise ArgumentError, "optional arg 'path' is invalid when 'path_prefix' is provided"
          end

          @path_prefix = params.delete(:path_prefix)
        end

        params[:debug_response] = true unless params.key?(:debug_response)
        params[:headers] ||= {}
        params.merge!(:persistent => params.fetch(:persistent, persistent))
        params[:headers]["User-Agent"] ||= user_agent
        @excon = Excon.new(url, params)
      end

      # Makes a request using the connection using Excon
      #
      # @param [Hash] params
      # @option params [String] :body text to be sent over a socket
      # @option params [Hash<Symbol, String>] :headers The default headers to supply in a request
      # @option params [String] :host The destination host's reachable DNS name or IP, in the form of a String
      # @option params [String] :path appears after 'scheme://host:port/'
      # @option params [Fixnum] :port The port on which to connect, to the destination host
      # @option params [Hash]   :query appended to the 'scheme://host:port/path/' in the form of '?key=value'
      # @option params [String] :scheme The protocol; 'https' causes OpenSSL to be used
      # @option params [Proc] :response_block
      #
      # @return [Excon::Response]
      #
      # @raise [Excon::Errors::StubNotFound]
      # @raise [Excon::Errors::Timeout]
      # @raise [Excon::Errors::SocketError]
      #
      def request(params, &block)
        @excon.request(handle_path_prefix_for(params), &block)
      end

      # Make {#request} available even when it has been overidden by a subclass
      # to allow backwards compatibility.
      #
      alias_method :original_request, :request
      protected :original_request

      # Closes the connection
      #
      def reset
        @excon.reset
      end

      private

      def user_agent
        self.class.user_agents
      end

      def handle_path_prefix_for(params)
        return params unless @path_prefix

        params[:path] = params[:path].sub(/^\//, "")
        params[:path] = "#{@path_prefix}/#{params[:path]}"
        params
      end
    end
  end
end
