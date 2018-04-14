module WebSocket
  class Driver

    class Hybi < Driver
      root = File.expand_path('../hybi', __FILE__)

      autoload :Frame,   root + '/frame'
      autoload :Message, root + '/message'

      def self.generate_accept(key)
        Base64.strict_encode64(Digest::SHA1.digest(key + GUID))
      end

      GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

      BYTE       = 0b11111111
      FIN = MASK = 0b10000000
      RSV1       = 0b01000000
      RSV2       = 0b00100000
      RSV3       = 0b00010000
      OPCODE     = 0b00001111
      LENGTH     = 0b01111111

      OPCODES = {
        :continuation => 0,
        :text         => 1,
        :binary       => 2,
        :close        => 8,
        :ping         => 9,
        :pong         => 10
      }

      OPCODE_CODES    = OPCODES.values
      MESSAGE_OPCODES = OPCODES.values_at(:continuation, :text, :binary)
      OPENING_OPCODES = OPCODES.values_at(:text, :binary)

      ERRORS = {
        :normal_closure       => 1000,
        :going_away           => 1001,
        :protocol_error       => 1002,
        :unacceptable         => 1003,
        :encoding_error       => 1007,
        :policy_violation     => 1008,
        :too_large            => 1009,
        :extension_error      => 1010,
        :unexpected_condition => 1011
      }

      ERROR_CODES        = ERRORS.values
      DEFAULT_ERROR_CODE = 1000
      MIN_RESERVED_ERROR = 3000
      MAX_RESERVED_ERROR = 4999

      PACK_FORMATS = {2 => 'n', 8 => 'Q>'}

      def initialize(socket, options = {})
        super

        @extensions      = ::WebSocket::Extensions.new
        @stage           = 0
        @masking         = options[:masking]
        @protocols       = options[:protocols] || []
        @protocols       = @protocols.strip.split(/ *, */) if String === @protocols
        @require_masking = options[:require_masking]
        @ping_callbacks  = {}

        @frame = @message = nil

        return unless @socket.respond_to?(:env)

        sec_key = @socket.env['HTTP_SEC_WEBSOCKET_KEY']
        protos  = @socket.env['HTTP_SEC_WEBSOCKET_PROTOCOL']

        @headers['Upgrade']              = 'websocket'
        @headers['Connection']           = 'Upgrade'
        @headers['Sec-WebSocket-Accept'] = Hybi.generate_accept(sec_key)

        if protos = @socket.env['HTTP_SEC_WEBSOCKET_PROTOCOL']
          protos = protos.split(/ *, */) if String === protos
          @protocol = protos.find { |p| @protocols.include?(p) }
          @headers['Sec-WebSocket-Protocol'] = @protocol if @protocol
        end
      end

      def version
        "hybi-#{@socket.env['HTTP_SEC_WEBSOCKET_VERSION']}"
      end

      def add_extension(extension)
        @extensions.add(extension)
        true
      end

      def parse(chunk)
        @reader.put(chunk)
        buffer = true
        while buffer
          case @stage
            when 0 then
              buffer = @reader.read(1)
              parse_opcode(buffer.getbyte(0)) if buffer

            when 1 then
              buffer = @reader.read(1)
              parse_length(buffer.getbyte(0)) if buffer

            when 2 then
              buffer = @reader.read(@frame.length_bytes)
              parse_extended_length(buffer) if buffer

            when 3 then
              buffer = @reader.read(4)
              if buffer
                @stage = 4
                @frame.masking_key = buffer
              end

            when 4 then
              buffer = @reader.read(@frame.length)

              if buffer
                @stage = 0
                emit_frame(buffer)
              end

            else
              buffer = nil
          end
        end
      end

      def binary(message)
        frame(message, :binary)
      end

      def ping(message = '', &callback)
        @ping_callbacks[message] = callback if callback
        frame(message, :ping)
      end

      def pong(message = '')
        frame(message, :pong)
      end

      def close(reason = nil, code = nil)
        reason ||= ''
        code   ||= ERRORS[:normal_closure]

        if @ready_state <= 0
          @ready_state = 3
          emit(:close, CloseEvent.new(code, reason))
          true
        elsif @ready_state == 1
          frame(reason, :close, code)
          @ready_state = 2
          true
        else
          false
        end
      end

      def frame(buffer, type = nil, code = nil)
        return queue([buffer, type, code]) if @ready_state <= 0
        return false unless @ready_state == 1

        message = Message.new
        frame   = Frame.new
        is_text = String === buffer

        message.rsv1   = message.rsv2 = message.rsv3 = false
        message.opcode = OPCODES[type || (is_text ? :text : :binary)]

        payload = is_text ? buffer.bytes.to_a : buffer
        payload = [code].pack(PACK_FORMATS[2]).bytes.to_a + payload if code
        message.data = payload.pack('C*')

        if MESSAGE_OPCODES.include?(message.opcode)
          message = @extensions.process_outgoing_message(message)
        end

        frame.final       = true
        frame.rsv1        = message.rsv1
        frame.rsv2        = message.rsv2
        frame.rsv3        = message.rsv3
        frame.opcode      = message.opcode
        frame.masked      = !!@masking
        frame.masking_key = SecureRandom.random_bytes(4) if frame.masked
        frame.length      = message.data.bytesize
        frame.payload     = message.data

        send_frame(frame)
        true

      rescue ::WebSocket::Extensions::ExtensionError => error
        fail(:extension_error, error.message)
      end

    private

      def send_frame(frame)
        length = frame.length
        buffer = []
        masked = frame.masked ? MASK : 0

        buffer[0] = (frame.final ? FIN : 0) |
                    (frame.rsv1 ? RSV1 : 0) |
                    (frame.rsv2 ? RSV2 : 0) |
                    (frame.rsv3 ? RSV3 : 0) |
                    frame.opcode

        if length <= 125
          buffer[1] = masked | length
        elsif length <= 65535
          buffer[1] = masked | 126
          buffer[2..3] = [length].pack(PACK_FORMATS[2]).bytes.to_a
        else
          buffer[1] = masked | 127
          buffer[2..9] = [length].pack(PACK_FORMATS[8]).bytes.to_a
        end

        if frame.masked
          buffer.concat(frame.masking_key.bytes.to_a)
          buffer.concat(Mask.mask(frame.payload, frame.masking_key).bytes.to_a)
        else
          buffer.concat(frame.payload.bytes.to_a)
        end

        @socket.write(buffer.pack('C*'))
      end

      def handshake_response
        begin
          extensions = @extensions.generate_response(@socket.env['HTTP_SEC_WEBSOCKET_EXTENSIONS'])
        rescue => error
          fail(:protocol_error, error.message)
          return nil
        end

        @headers['Sec-WebSocket-Extensions'] = extensions if extensions

        start   = 'HTTP/1.1 101 Switching Protocols'
        headers = [start, @headers.to_s, '']
        headers.join("\r\n")
      end

      def shutdown(code, reason, error = false)
        @frame = @message = nil
        @stage = 5
        @extensions.close

        frame(reason, :close, code) if @ready_state < 2
        @ready_state = 3

        emit(:error, ProtocolError.new(reason)) if error
        emit(:close, CloseEvent.new(code, reason))
      end

      def fail(type, message)
        return if @ready_state > 1
        shutdown(ERRORS[type], message, true)
      end

      def parse_opcode(octet)
        rsvs = [RSV1, RSV2, RSV3].map { |rsv| (octet & rsv) == rsv }

        @frame = Frame.new

        @frame.final  = (octet & FIN) == FIN
        @frame.rsv1   = rsvs[0]
        @frame.rsv2   = rsvs[1]
        @frame.rsv3   = rsvs[2]
        @frame.opcode = (octet & OPCODE)

        @stage = 1

        unless @extensions.valid_frame_rsv?(@frame)
          return fail(:protocol_error,
              "One or more reserved bits are on: reserved1 = #{@frame.rsv1 ? 1 : 0}" +
              ", reserved2 = #{@frame.rsv2 ? 1 : 0 }" +
              ", reserved3 = #{@frame.rsv3 ? 1 : 0 }")
        end

        unless OPCODES.values.include?(@frame.opcode)
          return fail(:protocol_error, "Unrecognized frame opcode: #{@frame.opcode}")
        end

        unless MESSAGE_OPCODES.include?(@frame.opcode) or @frame.final
          return fail(:protocol_error, "Received fragmented control frame: opcode = #{@frame.opcode}")
        end

        if @message and OPENING_OPCODES.include?(@frame.opcode)
          return fail(:protocol_error, 'Received new data frame but previous continuous frame is unfinished')
        end
      end

      def parse_length(octet)
        @frame.masked = (octet & MASK) == MASK
        @frame.length = (octet & LENGTH)

        if @frame.length >= 0 and @frame.length <= 125
          @stage = @frame.masked ? 3 : 4
          return unless check_frame_length
        else
          @stage = 2
          @frame.length_bytes = (@frame.length == 126) ? 2 : 8
        end

        if @require_masking and not @frame.masked
          return fail(:unacceptable, 'Received unmasked frame but masking is required')
        end
      end

      def parse_extended_length(buffer)
        @frame.length = buffer.unpack(PACK_FORMATS[buffer.bytesize]).first
        @stage = @frame.masked ? 3 : 4

        unless MESSAGE_OPCODES.include?(@frame.opcode) or @frame.length <= 125
          return fail(:protocol_error, "Received control frame having too long payload: #{@frame.length}")
        end

        return unless check_frame_length
      end

      def check_frame_length
        length = @message ? @message.data.bytesize : 0

        if length + @frame.length > @max_length
          fail(:too_large, 'WebSocket frame length too large')
          false
        else
          true
        end
      end

      def emit_frame(buffer)
        frame    = @frame
        opcode   = frame.opcode
        payload  = frame.payload = Mask.mask(buffer, @frame.masking_key)
        bytesize = payload.bytesize
        bytes    = payload.bytes.to_a

        @frame = nil

        case opcode
          when OPCODES[:continuation] then
            return fail(:protocol_error, 'Received unexpected continuation frame') unless @message
            @message << frame

          when OPCODES[:text], OPCODES[:binary] then
            @message = Message.new
            @message << frame

          when OPCODES[:close] then
            code   = (bytesize >= 2) ? payload.unpack(PACK_FORMATS[2]).first : nil
            reason = (bytesize > 2)  ? Driver.encode(bytes[2..-1] || [], UNICODE) : nil

            unless (bytesize == 0) or
                   (code && code >= MIN_RESERVED_ERROR && code <= MAX_RESERVED_ERROR) or
                   ERROR_CODES.include?(code)
              code = ERRORS[:protocol_error]
            end

            if bytesize > 125 or (bytesize > 2 and reason.nil?)
              code = ERRORS[:protocol_error]
            end

            shutdown(code || DEFAULT_ERROR_CODE, reason || '')

          when OPCODES[:ping] then
            frame(payload, :pong)

          when OPCODES[:pong] then
            message = Driver.encode(payload, UNICODE)
            callback = @ping_callbacks[message]
            @ping_callbacks.delete(message)
            callback.call if callback
        end

        emit_message if frame.final and MESSAGE_OPCODES.include?(opcode)
      end

      def emit_message
        message  = @extensions.process_incoming_message(@message)
        @message = nil

        payload = message.data

        case message.opcode
          when OPCODES[:text] then
            payload = Driver.encode(payload, UNICODE)
          when OPCODES[:binary]
            payload = payload.bytes.to_a
        end

        if payload
          emit(:message, MessageEvent.new(payload))
        else
          fail(:encoding_error, 'Could not decode a text frame as UTF-8')
        end
      rescue ::WebSocket::Extensions::ExtensionError => error
        fail(:extension_error, error.message)
      end
    end

  end
end
