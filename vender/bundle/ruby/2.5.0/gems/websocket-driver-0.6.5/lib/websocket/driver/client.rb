module WebSocket
  class Driver

    class Client < Hybi
      VALID_SCHEMES = %w[ws wss]

      def self.generate_key
        Base64.strict_encode64(SecureRandom.random_bytes(16))
      end

      attr_reader :status, :headers

      def initialize(socket, options = {})
        super

        @ready_state = -1
        @key         = Client.generate_key
        @accept      = Hybi.generate_accept(@key)
        @http        = HTTP::Response.new

        uri = URI.parse(@socket.url)
        unless VALID_SCHEMES.include?(uri.scheme)
          raise URIError, "#{socket.url} is not a valid WebSocket URL"
        end

        host      = uri.host + (uri.port ? ":#{uri.port}" : '')
        path      = (uri.path == '') ? '/' : uri.path
        @pathname = path + (uri.query ? '?' + uri.query : '')

        @headers['Host']                  = host
        @headers['Upgrade']               = 'websocket'
        @headers['Connection']            = 'Upgrade'
        @headers['Sec-WebSocket-Key']     = @key
        @headers['Sec-WebSocket-Version'] = '13'

        if @protocols.size > 0
          @headers['Sec-WebSocket-Protocol'] = @protocols * ', '
        end

        if uri.user
          auth = Base64.strict_encode64([uri.user, uri.password] * ':')
          @headers['Authorization'] = 'Basic ' + auth
        end
      end

      def version
        'hybi-13'
      end

      def proxy(origin, options = {})
        Proxy.new(self, origin, options)
      end

      def start
        return false unless @ready_state == -1
        @socket.write(handshake_request)
        @ready_state = 0
        true
      end

      def parse(chunk)
        return if @ready_state == 3
        return super if @ready_state > 0

        @http.parse(chunk)
        return fail_handshake('Invalid HTTP response') if @http.error?
        return unless @http.complete?

        validate_handshake
        return if @ready_state == 3

        open
        parse(@http.body)
      end

    private 

      def handshake_request
        extensions = @extensions.generate_offer
        @headers['Sec-WebSocket-Extensions'] = extensions if extensions

        start   = "GET #{@pathname} HTTP/1.1"
        headers = [start, @headers.to_s, '']
        headers.join("\r\n")
      end

      def fail_handshake(message)
        message = "Error during WebSocket handshake: #{message}"
        @ready_state = 3
        emit(:error, ProtocolError.new(message))
        emit(:close, CloseEvent.new(ERRORS[:protocol_error], message))
      end

      def validate_handshake
        @status  = @http.code
        @headers = Headers.new(@http.headers)

        unless @http.code == 101
          return fail_handshake("Unexpected response code: #{@http.code}")
        end

        upgrade    = @http['Upgrade'] || ''
        connection = @http['Connection'] || ''
        accept     = @http['Sec-WebSocket-Accept'] || ''
        protocol   = @http['Sec-WebSocket-Protocol'] || ''

        if upgrade == ''
          return fail_handshake("'Upgrade' header is missing")
        elsif upgrade.downcase != 'websocket'
          return fail_handshake("'Upgrade' header value is not 'WebSocket'")
        end

        if connection == ''
          return fail_handshake("'Connection' header is missing")
        elsif connection.downcase != 'upgrade'
          return fail_handshake("'Connection' header value is not 'Upgrade'")
        end

        unless accept == @accept
          return fail_handshake('Sec-WebSocket-Accept mismatch')
        end

        unless protocol == ''
          if @protocols.include?(protocol)
            @protocol = protocol
          else
            return fail_handshake('Sec-WebSocket-Protocol mismatch')
          end
        end

        begin
          @extensions.activate(@headers['Sec-WebSocket-Extensions'])
        rescue ::WebSocket::Extensions::ExtensionError => error
          return fail_handshake(error.message)
        end
      end
    end

  end
end
