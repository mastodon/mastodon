require 'rack/utils'
require 'rack/media_type'

module Rack
  # Rack::Request provides a convenient interface to a Rack
  # environment.  It is stateless, the environment +env+ passed to the
  # constructor will be directly modified.
  #
  #   req = Rack::Request.new(env)
  #   req.post?
  #   req.params["data"]

  class Request
    def initialize(env)
      @params = nil
      super(env)
    end

    def params
      @params ||= super
    end

    def update_param(k, v)
      super
      @params = nil
    end

    def delete_param(k)
      v = super
      @params = nil
      v
    end

    module Env
      # The environment of the request.
      attr_reader :env

      def initialize(env)
        @env = env
        super()
      end

      # Predicate method to test to see if `name` has been set as request
      # specific data
      def has_header?(name)
        @env.key? name
      end

      # Get a request specific value for `name`.
      def get_header(name)
        @env[name]
      end

      # If a block is given, it yields to the block if the value hasn't been set
      # on the request.
      def fetch_header(name, &block)
        @env.fetch(name, &block)
      end

      # Loops through each key / value pair in the request specific data.
      def each_header(&block)
        @env.each(&block)
      end

      # Set a request specific value for `name` to `v`
      def set_header(name, v)
        @env[name] = v
      end

      # Add a header that may have multiple values.
      #
      # Example:
      #   request.add_header 'Accept', 'image/png'
      #   request.add_header 'Accept', '*/*'
      #
      #   assert_equal 'image/png,*/*', request.get_header('Accept')
      #
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
      def add_header key, v
        if v.nil?
          get_header key
        elsif has_header? key
          set_header key, "#{get_header key},#{v}"
        else
          set_header key, v
        end
      end

      # Delete a request specific value for `name`.
      def delete_header(name)
        @env.delete name
      end

      def initialize_copy(other)
        @env = other.env.dup
      end
    end

    module Helpers
      # The set of form-data media-types. Requests that do not indicate
      # one of the media types presents in this list will not be eligible
      # for form-data / param parsing.
      FORM_DATA_MEDIA_TYPES = [
        'application/x-www-form-urlencoded',
        'multipart/form-data'
      ]

      # The set of media-types. Requests that do not indicate
      # one of the media types presents in this list will not be eligible
      # for param parsing like soap attachments or generic multiparts
      PARSEABLE_DATA_MEDIA_TYPES = [
        'multipart/related',
        'multipart/mixed'
      ]

      # Default ports depending on scheme. Used to decide whether or not
      # to include the port in a generated URI.
      DEFAULT_PORTS = { 'http' => 80, 'https' => 443, 'coffee' => 80 }

      HTTP_X_FORWARDED_SCHEME = 'HTTP_X_FORWARDED_SCHEME'.freeze
      HTTP_X_FORWARDED_PROTO  = 'HTTP_X_FORWARDED_PROTO'.freeze
      HTTP_X_FORWARDED_HOST   = 'HTTP_X_FORWARDED_HOST'.freeze
      HTTP_X_FORWARDED_PORT   = 'HTTP_X_FORWARDED_PORT'.freeze
      HTTP_X_FORWARDED_SSL    = 'HTTP_X_FORWARDED_SSL'.freeze

      def body;            get_header(RACK_INPUT)                         end
      def script_name;     get_header(SCRIPT_NAME).to_s                   end
      def script_name=(s); set_header(SCRIPT_NAME, s.to_s)                end

      def path_info;       get_header(PATH_INFO).to_s                     end
      def path_info=(s);   set_header(PATH_INFO, s.to_s)                  end

      def request_method;  get_header(REQUEST_METHOD)                     end
      def query_string;    get_header(QUERY_STRING).to_s                  end
      def content_length;  get_header('CONTENT_LENGTH')                   end
      def logger;          get_header(RACK_LOGGER)                        end
      def user_agent;      get_header('HTTP_USER_AGENT')                  end
      def multithread?;    get_header(RACK_MULTITHREAD)                   end

      # the referer of the client
      def referer;         get_header('HTTP_REFERER')                     end
      alias referrer referer

      def session
        fetch_header(RACK_SESSION) do |k|
          set_header RACK_SESSION, default_session
        end
      end

      def session_options
        fetch_header(RACK_SESSION_OPTIONS) do |k|
          set_header RACK_SESSION_OPTIONS, {}
        end
      end

      # Checks the HTTP request method (or verb) to see if it was of type DELETE
      def delete?;  request_method == DELETE  end

      # Checks the HTTP request method (or verb) to see if it was of type GET
      def get?;     request_method == GET       end

      # Checks the HTTP request method (or verb) to see if it was of type HEAD
      def head?;    request_method == HEAD      end

      # Checks the HTTP request method (or verb) to see if it was of type OPTIONS
      def options?; request_method == OPTIONS end

      # Checks the HTTP request method (or verb) to see if it was of type LINK
      def link?;    request_method == LINK    end

      # Checks the HTTP request method (or verb) to see if it was of type PATCH
      def patch?;   request_method == PATCH   end

      # Checks the HTTP request method (or verb) to see if it was of type POST
      def post?;    request_method == POST    end

      # Checks the HTTP request method (or verb) to see if it was of type PUT
      def put?;     request_method == PUT     end

      # Checks the HTTP request method (or verb) to see if it was of type TRACE
      def trace?;   request_method == TRACE   end

      # Checks the HTTP request method (or verb) to see if it was of type UNLINK
      def unlink?;  request_method == UNLINK  end

      def scheme
        if get_header(HTTPS) == 'on'
          'https'
        elsif get_header(HTTP_X_FORWARDED_SSL) == 'on'
          'https'
        elsif get_header(HTTP_X_FORWARDED_SCHEME)
          get_header(HTTP_X_FORWARDED_SCHEME)
        elsif get_header(HTTP_X_FORWARDED_PROTO)
          get_header(HTTP_X_FORWARDED_PROTO).split(',')[0]
        else
          get_header(RACK_URL_SCHEME)
        end
      end

      def authority
        get_header(SERVER_NAME) + ':' + get_header(SERVER_PORT)
      end

      def cookies
        hash = fetch_header(RACK_REQUEST_COOKIE_HASH) do |k|
          set_header(k, {})
        end
        string = get_header HTTP_COOKIE

        return hash if string == get_header(RACK_REQUEST_COOKIE_STRING)
        hash.replace Utils.parse_cookies_header get_header HTTP_COOKIE
        set_header(RACK_REQUEST_COOKIE_STRING, string)
        hash
      end

      def content_type
        content_type = get_header('CONTENT_TYPE')
        content_type.nil? || content_type.empty? ? nil : content_type
      end

      def xhr?
        get_header("HTTP_X_REQUESTED_WITH") == "XMLHttpRequest"
      end

      def host_with_port
        if forwarded = get_header(HTTP_X_FORWARDED_HOST)
          forwarded.split(/,\s?/).last
        else
          get_header(HTTP_HOST) || "#{get_header(SERVER_NAME) || get_header(SERVER_ADDR)}:#{get_header(SERVER_PORT)}"
        end
      end

      def host
        # Remove port number.
        host_with_port.to_s.sub(/:\d+\z/, '')
      end

      def port
        if port = host_with_port.split(/:/)[1]
          port.to_i
        elsif port = get_header(HTTP_X_FORWARDED_PORT)
          port.to_i
        elsif has_header?(HTTP_X_FORWARDED_HOST)
          DEFAULT_PORTS[scheme]
        elsif has_header?(HTTP_X_FORWARDED_PROTO)
          DEFAULT_PORTS[get_header(HTTP_X_FORWARDED_PROTO).split(',')[0]]
        else
          get_header(SERVER_PORT).to_i
        end
      end

      def ssl?
        scheme == 'https'
      end

      def ip
        remote_addrs = split_ip_addresses(get_header('REMOTE_ADDR'))
        remote_addrs = reject_trusted_ip_addresses(remote_addrs)

        return remote_addrs.first if remote_addrs.any?

        forwarded_ips = split_ip_addresses(get_header('HTTP_X_FORWARDED_FOR'))

        return reject_trusted_ip_addresses(forwarded_ips).last || get_header("REMOTE_ADDR")
      end

      # The media type (type/subtype) portion of the CONTENT_TYPE header
      # without any media type parameters. e.g., when CONTENT_TYPE is
      # "text/plain;charset=utf-8", the media-type is "text/plain".
      #
      # For more information on the use of media types in HTTP, see:
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.7
      def media_type
        MediaType.type(content_type)
      end

      # The media type parameters provided in CONTENT_TYPE as a Hash, or
      # an empty Hash if no CONTENT_TYPE or media-type parameters were
      # provided.  e.g., when the CONTENT_TYPE is "text/plain;charset=utf-8",
      # this method responds with the following Hash:
      #   { 'charset' => 'utf-8' }
      def media_type_params
        MediaType.params(content_type)
      end

      # The character set of the request body if a "charset" media type
      # parameter was given, or nil if no "charset" was specified. Note
      # that, per RFC2616, text/* media types that specify no explicit
      # charset are to be considered ISO-8859-1.
      def content_charset
        media_type_params['charset']
      end

      # Determine whether the request body contains form-data by checking
      # the request Content-Type for one of the media-types:
      # "application/x-www-form-urlencoded" or "multipart/form-data". The
      # list of form-data media types can be modified through the
      # +FORM_DATA_MEDIA_TYPES+ array.
      #
      # A request body is also assumed to contain form-data when no
      # Content-Type header is provided and the request_method is POST.
      def form_data?
        type = media_type
        meth = get_header(RACK_METHODOVERRIDE_ORIGINAL_METHOD) || get_header(REQUEST_METHOD)
        (meth == POST && type.nil?) || FORM_DATA_MEDIA_TYPES.include?(type)
      end

      # Determine whether the request body contains data by checking
      # the request media_type against registered parse-data media-types
      def parseable_data?
        PARSEABLE_DATA_MEDIA_TYPES.include?(media_type)
      end

      # Returns the data received in the query string.
      def GET
        if get_header(RACK_REQUEST_QUERY_STRING) == query_string
          get_header(RACK_REQUEST_QUERY_HASH)
        else
          query_hash = parse_query(query_string, '&;')
          set_header(RACK_REQUEST_QUERY_STRING, query_string)
          set_header(RACK_REQUEST_QUERY_HASH, query_hash)
        end
      end

      # Returns the data received in the request body.
      #
      # This method support both application/x-www-form-urlencoded and
      # multipart/form-data.
      def POST
        if get_header(RACK_INPUT).nil?
          raise "Missing rack.input"
        elsif get_header(RACK_REQUEST_FORM_INPUT) == get_header(RACK_INPUT)
          get_header(RACK_REQUEST_FORM_HASH)
        elsif form_data? || parseable_data?
          unless set_header(RACK_REQUEST_FORM_HASH, parse_multipart)
            form_vars = get_header(RACK_INPUT).read

            # Fix for Safari Ajax postings that always append \0
            # form_vars.sub!(/\0\z/, '') # performance replacement:
            form_vars.slice!(-1) if form_vars[-1] == ?\0

            set_header RACK_REQUEST_FORM_VARS, form_vars
            set_header RACK_REQUEST_FORM_HASH, parse_query(form_vars, '&')

            get_header(RACK_INPUT).rewind
          end
          set_header RACK_REQUEST_FORM_INPUT, get_header(RACK_INPUT)
          get_header RACK_REQUEST_FORM_HASH
        else
          {}
        end
      end

      # The union of GET and POST data.
      #
      # Note that modifications will not be persisted in the env. Use update_param or delete_param if you want to destructively modify params.
      def params
        self.GET.merge(self.POST)
      rescue EOFError
        self.GET.dup
      end

      # Destructively update a parameter, whether it's in GET and/or POST. Returns nil.
      #
      # The parameter is updated wherever it was previous defined, so GET, POST, or both. If it wasn't previously defined, it's inserted into GET.
      #
      # <tt>env['rack.input']</tt> is not touched.
      def update_param(k, v)
        found = false
        if self.GET.has_key?(k)
          found = true
          self.GET[k] = v
        end
        if self.POST.has_key?(k)
          found = true
          self.POST[k] = v
        end
        unless found
          self.GET[k] = v
        end
      end

      # Destructively delete a parameter, whether it's in GET or POST. Returns the value of the deleted parameter.
      #
      # If the parameter is in both GET and POST, the POST value takes precedence since that's how #params works.
      #
      # <tt>env['rack.input']</tt> is not touched.
      def delete_param(k)
        [ self.POST.delete(k), self.GET.delete(k) ].compact.first
      end

      def base_url
        url = "#{scheme}://#{host}"
        url << ":#{port}" if port != DEFAULT_PORTS[scheme]
        url
      end

      # Tries to return a remake of the original request URL as a string.
      def url
        base_url + fullpath
      end

      def path
        script_name + path_info
      end

      def fullpath
        query_string.empty? ? path : "#{path}?#{query_string}"
      end

      def accept_encoding
        parse_http_accept_header(get_header("HTTP_ACCEPT_ENCODING"))
      end

      def accept_language
        parse_http_accept_header(get_header("HTTP_ACCEPT_LANGUAGE"))
      end

      def trusted_proxy?(ip)
        ip =~ /\A127\.0\.0\.1\Z|\A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|\A::1\Z|\Afd[0-9a-f]{2}:.+|\Alocalhost\Z|\Aunix\Z|\Aunix:/i
      end

      # shortcut for <tt>request.params[key]</tt>
      def [](key)
        if $VERBOSE
          warn("Request#[] is deprecated and will be removed in a future version of Rack. Please use request.params[] instead")
        end

        params[key.to_s]
      end

      # shortcut for <tt>request.params[key] = value</tt>
      #
      # Note that modifications will not be persisted in the env. Use update_param or delete_param if you want to destructively modify params.
      def []=(key, value)
        if $VERBOSE
          warn("Request#[]= is deprecated and will be removed in a future version of Rack. Please use request.params[]= instead")
        end

        params[key.to_s] = value
      end

      # like Hash#values_at
      def values_at(*keys)
        keys.map { |key| params[key] }
      end

      private

      def default_session; {}; end

      def parse_http_accept_header(header)
        header.to_s.split(/\s*,\s*/).map do |part|
          attribute, parameters = part.split(/\s*;\s*/, 2)
          quality = 1.0
          if parameters and /\Aq=([\d.]+)/ =~ parameters
            quality = $1.to_f
          end
          [attribute, quality]
        end
      end

      def query_parser
        Utils.default_query_parser
      end

      def parse_query(qs, d='&')
        query_parser.parse_nested_query(qs, d)
      end

      def parse_multipart
        Rack::Multipart.extract_multipart(self, query_parser)
      end

      def split_ip_addresses(ip_addresses)
        ip_addresses ? ip_addresses.strip.split(/[,\s]+/) : []
      end

      def reject_trusted_ip_addresses(ip_addresses)
        ip_addresses.reject { |ip| trusted_proxy?(ip) }
      end
    end

    include Env
    include Helpers
  end
end
