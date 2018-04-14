module WebSocket
  class Driver

    class Proxy
      include EventEmitter

      PORTS = {'ws' => 80, 'wss' => 443}

      attr_reader :status, :headers

      def initialize(client, origin, options)
        super()

        @client  = client
        @http    = HTTP::Response.new
        @socket  = client.instance_variable_get(:@socket)
        @origin  = URI.parse(@socket.url)
        @url     = URI.parse(origin)
        @options = options
        @state   = 0

        @headers = Headers.new
        @headers['Host'] = @origin.host + (@origin.port ? ":#{@origin.port}" : '')
        @headers['Connection'] = 'keep-alive'
        @headers['Proxy-Connection'] = 'keep-alive'

        if @url.user
          auth = Base64.strict_encode64([@url.user, @url.password] * ':')
          @headers['Proxy-Authorization'] = 'Basic ' + auth
        end
      end

      def set_header(name, value)
        return false unless @state == 0
        @headers[name] = value
        true
      end

      def start
        return false unless @state == 0
        @state = 1

        port    = @origin.port || PORTS[@origin.scheme]
        start   = "CONNECT #{@origin.host}:#{port} HTTP/1.1"
        headers = [start, @headers.to_s, '']

        @socket.write(headers.join("\r\n"))
        true
      end

      def parse(chunk)
        @http.parse(chunk)
        return unless @http.complete?

        @status  = @http.code
        @headers = Headers.new(@http.headers)

        if @status == 200
          emit(:connect, ConnectEvent.new)
        else
          message = "Can't establish a connection to the server at #{@socket.url}"
          emit(:error, ProtocolError.new(message))
        end
      end
    end

  end
end
