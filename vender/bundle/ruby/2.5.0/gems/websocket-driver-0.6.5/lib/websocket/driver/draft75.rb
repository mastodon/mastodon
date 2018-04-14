module WebSocket
  class Driver

    class Draft75 < Driver
      def initialize(socket, options = {})
        super

        @stage   = 0
        @closing = false

        @headers['Upgrade']            = 'WebSocket'
        @headers['Connection']         = 'Upgrade'
        @headers['WebSocket-Origin']   = @socket.env['HTTP_ORIGIN']
        @headers['WebSocket-Location'] = @socket.url
      end

      def version
        'hixie-75'
      end

      def close(reason = nil, code = nil)
        return false if @ready_state == 3
        @ready_state = 3
        emit(:close, CloseEvent.new(nil, nil))
        true
      end

      def parse(chunk)
        return if @ready_state > 1

        @reader.put(chunk)

        @reader.each_byte do |octet|
          case @stage
            when -1 then
              @body << octet
              send_handshake_body

            when 0 then
              parse_leading_byte(octet)

            when 1 then
              @length = (octet & 0x7F) + 128 * @length

              if @closing and @length.zero?
                return close
              elsif (octet & 0x80) != 0x80
                if @length.zero?
                  @stage = 0
                else
                  @skipped = 0
                  @stage   = 2
                end
              end

            when 2 then
              if octet == 0xFF
                @stage = 0
                emit(:message, MessageEvent.new(Driver.encode(@buffer, UNICODE)))
              else
                if @length
                  @skipped += 1
                  @stage = 0 if @skipped == @length
                else
                  @buffer << octet
                  return close if @buffer.size > @max_length
                end
              end
          end
        end
      end

      def frame(buffer, type = nil, error_type = nil)
        return queue([buffer, type, error_type]) if @ready_state == 0
        frame = [0x00, buffer, 0xFF].pack('CA*C')
        @socket.write(frame)
        true
      end

    private

      def handshake_response
        start   = 'HTTP/1.1 101 Web Socket Protocol Handshake'
        headers = [start, @headers.to_s, '']
        headers.join("\r\n")
      end

      def parse_leading_byte(octet)
        if (octet & 0x80) == 0x80
          @length = 0
          @stage  = 1
        else
          @length  = nil
          @skipped = nil
          @buffer  = []
          @stage   = 2
        end
      end
    end

  end
end
