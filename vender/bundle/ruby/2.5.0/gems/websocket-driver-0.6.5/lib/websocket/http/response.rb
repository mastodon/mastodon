module WebSocket
  module HTTP

    class Response
      include Headers

      STATUS_LINE = /^(HTTP\/[0-9]+\.[0-9]+) ([0-9]{3}) ([\x20-\x7e]+)$/

      attr_reader :code

      def [](name)
        @headers[HTTP.normalize_header(name)]
      end

      def body
        @buffer.pack('C*')
      end

    private

      def start_line(line)
        return false unless parsed = line.scan(STATUS_LINE).first
        @code = parsed[1].to_i
        true
      end
    end

  end
end
