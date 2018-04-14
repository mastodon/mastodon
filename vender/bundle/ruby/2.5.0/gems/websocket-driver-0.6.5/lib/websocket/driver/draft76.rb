module WebSocket
  class Driver

    class Draft76 < Draft75
      BODY_SIZE = 8

      def initialize(socket, options = {})
        super
        input  = @socket.env['rack.input']
        @stage = -1
        @body  = (input ? input.read : String.new('')).force_encoding(BINARY)

        @headers.clear
        @headers['Upgrade'] = 'WebSocket'
        @headers['Connection'] = 'Upgrade'
        @headers['Sec-WebSocket-Origin'] = @socket.env['HTTP_ORIGIN']
        @headers['Sec-WebSocket-Location'] = @socket.url
      end

      def version
        'hixie-76'
      end

      def start
        return false unless super
        send_handshake_body
        true
      end

      def close(reason = nil, code = nil)
        return false if @ready_state == 3
        @socket.write([0xFF, 0x00].pack('C*'))
        @ready_state = 3
        emit(:close, CloseEvent.new(nil, nil))
        true
      end

    private

      def handshake_response
        env     = @socket.env

        key1    = env['HTTP_SEC_WEBSOCKET_KEY1']
        number1 = number_from_key(key1)
        spaces1 = spaces_in_key(key1)

        key2    = env['HTTP_SEC_WEBSOCKET_KEY2']
        number2 = number_from_key(key2)
        spaces2 = spaces_in_key(key2)

        if number1 % spaces1 != 0 or number2 % spaces2 != 0
          emit(:error, ProtocolError.new('Client sent invalid Sec-WebSocket-Key headers'))
          close
          return nil
        end

        @key_values = [number1 / spaces1, number2 / spaces2]

        start   = 'HTTP/1.1 101 WebSocket Protocol Handshake'
        headers = [start, @headers.to_s, '']
        headers.join("\r\n")
      end

      def handshake_signature
        return nil unless @body.bytesize >= BODY_SIZE

        head = @body[0...BODY_SIZE]
        Digest::MD5.digest((@key_values + [head]).pack('N2A*'))
      end

      def send_handshake_body
        return unless signature = handshake_signature
        @socket.write(signature)
        @stage = 0
        open
        parse(@body[BODY_SIZE..-1]) if @body.bytesize > BODY_SIZE
      end

      def parse_leading_byte(octet)
        return super unless octet == 0xFF
        @closing = true
        @length  = 0
        @stage   = 1
      end

      def number_from_key(key)
        key.scan(/[0-9]/).join('').to_i(10)
      end

      def spaces_in_key(key)
        key.scan(/ /).size
      end
    end

  end
end
