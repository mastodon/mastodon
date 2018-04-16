require 'rack/request'
require 'rack/utils'
require 'rack/body_proxy'
require 'rack/media_type'
require 'time'

module Rack
  # Rack::Response provides a convenient interface to create a Rack
  # response.
  #
  # It allows setting of headers and cookies, and provides useful
  # defaults (an OK response with empty headers and body).
  #
  # You can use Response#write to iteratively generate your response,
  # but note that this is buffered by Rack::Response until you call
  # +finish+.  +finish+ however can take a block inside which calls to
  # +write+ are synchronous with the Rack response.
  #
  # Your application's +call+ should end returning Response#finish.

  class Response
    attr_accessor :length, :status, :body
    attr_reader :header
    alias headers header

    CHUNKED = 'chunked'.freeze

    def initialize(body=[], status=200, header={})
      @status = status.to_i
      @header = Utils::HeaderHash.new.merge(header)

      @writer  = lambda { |x| @body << x }
      @block   = nil
      @length  = 0

      @body = []

      if body.respond_to? :to_str
        write body.to_str
      elsif body.respond_to?(:each)
        body.each { |part|
          write part.to_s
        }
      else
        raise TypeError, "stringable or iterable required"
      end

      yield self  if block_given?
    end

    def redirect(target, status=302)
      self.status = status
      self.location = target
    end

    def chunked?
      CHUNKED == get_header(TRANSFER_ENCODING)
    end

    def finish(&block)
      @block = block

      if [204, 304].include?(status.to_i)
        delete_header CONTENT_TYPE
        delete_header CONTENT_LENGTH
        close
        [status.to_i, header, []]
      else
        [status.to_i, header, BodyProxy.new(self){}]
      end
    end
    alias to_a finish           # For *response
    alias to_ary finish         # For implicit-splat on Ruby 1.9.2

    def each(&callback)
      @body.each(&callback)
      @writer = callback
      @block.call(self)  if @block
    end

    # Append to body and update Content-Length.
    #
    # NOTE: Do not mix #write and direct #body access!
    #
    def write(str)
      s = str.to_s
      @length += s.bytesize unless chunked?
      @writer.call s

      set_header(CONTENT_LENGTH, @length.to_s) unless chunked?
      str
    end

    def close
      body.close if body.respond_to?(:close)
    end

    def empty?
      @block == nil && @body.empty?
    end

    def has_header?(key);   headers.key? key;   end
    def get_header(key);    headers[key];       end
    def set_header(key, v); headers[key] = v;   end
    def delete_header(key); headers.delete key; end

    alias :[] :get_header
    alias :[]= :set_header

    module Helpers
      def invalid?;             status < 100 || status >= 600;        end

      def informational?;       status >= 100 && status < 200;        end
      def successful?;          status >= 200 && status < 300;        end
      def redirection?;         status >= 300 && status < 400;        end
      def client_error?;        status >= 400 && status < 500;        end
      def server_error?;        status >= 500 && status < 600;        end

      def ok?;                  status == 200;                        end
      def created?;             status == 201;                        end
      def accepted?;            status == 202;                        end
      def no_content?;          status == 204;                        end
      def moved_permanently?;   status == 301;                        end
      def bad_request?;         status == 400;                        end
      def unauthorized?;        status == 401;                        end
      def forbidden?;           status == 403;                        end
      def not_found?;           status == 404;                        end
      def method_not_allowed?;  status == 405;                        end
      def precondition_failed?; status == 412;                        end
      def unprocessable?;       status == 422;                        end

      def redirect?;            [301, 302, 303, 307, 308].include? status; end

      def include?(header)
        has_header? header
      end

      # Add a header that may have multiple values.
      #
      # Example:
      #   response.add_header 'Vary', 'Accept-Encoding'
      #   response.add_header 'Vary', 'Cookie'
      #
      #   assert_equal 'Accept-Encoding,Cookie', response.get_header('Vary')
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

      def content_type
        get_header CONTENT_TYPE
      end

      def media_type
        MediaType.type(content_type)
      end

      def media_type_params
        MediaType.params(content_type)
      end

      def content_length
        cl = get_header CONTENT_LENGTH
        cl ? cl.to_i : cl
      end

      def location
        get_header "Location"
      end

      def location=(location)
        set_header "Location", location
      end

      def set_cookie(key, value)
        cookie_header = get_header SET_COOKIE
        set_header SET_COOKIE, ::Rack::Utils.add_cookie_to_header(cookie_header, key, value)
      end

      def delete_cookie(key, value={})
        set_header SET_COOKIE, ::Rack::Utils.add_remove_cookie_to_header(get_header(SET_COOKIE), key, value)
      end

      def set_cookie_header
        get_header SET_COOKIE
      end

      def set_cookie_header= v
        set_header SET_COOKIE, v
      end

      def cache_control
        get_header CACHE_CONTROL
      end

      def cache_control= v
        set_header CACHE_CONTROL, v
      end

      def etag
        get_header ETAG
      end

      def etag= v
        set_header ETAG, v
      end
    end

    include Helpers

    class Raw
      include Helpers

      attr_reader :headers
      attr_accessor :status

      def initialize status, headers
        @status = status
        @headers = headers
      end

      def has_header?(key);   headers.key? key;   end
      def get_header(key);    headers[key];       end
      def set_header(key, v); headers[key] = v;   end
      def delete_header(key); headers.delete key; end
    end
  end
end
