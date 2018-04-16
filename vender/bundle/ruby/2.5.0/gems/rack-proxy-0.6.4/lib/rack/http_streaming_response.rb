require "net_http_hacked"

module Rack

  # Wraps the hacked net/http in a Rack way.
  class HttpStreamingResponse
    attr_accessor :use_ssl
    attr_accessor :verify_mode
    attr_accessor :read_timeout
    attr_accessor :ssl_version

    def initialize(request, host, port = nil)
      @request, @host, @port = request, host, port
    end

    def body
      self
    end

    def code
      response.code.to_i
    end
    # #status is deprecated
    alias_method :status, :code

    def headers
      h = Utils::HeaderHash.new

      response.to_hash.each do |k, v|
        h[k] = v
      end

      h
    end

    # Can be called only once!
    def each(&block)
      response.read_body(&block)
    ensure
      session.end_request_hacked
      session.finish
    end

    def to_s
      @body ||= begin
        lines = []

        each do |line|
          lines << line
        end

        lines.join
      end
    end

    protected

    # Net::HTTPResponse
    def response
      @response ||= session.begin_request_hacked(@request)
    end

    # Net::HTTP
    def session
      @session ||= begin
        http = Net::HTTP.new @host, @port
        http.use_ssl = self.use_ssl
        http.verify_mode = self.verify_mode
        http.read_timeout = self.read_timeout
        http.ssl_version = self.ssl_version if self.use_ssl
        http.start
      end
    end

  end

end
