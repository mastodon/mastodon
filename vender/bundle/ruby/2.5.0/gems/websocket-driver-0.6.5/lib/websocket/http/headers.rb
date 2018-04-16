module WebSocket
  module HTTP

    module Headers
      MAX_LINE_LENGTH = 4096
      CR = 0x0D
      LF = 0x0A

      # RFC 2616 grammar rules:
      #
      #       CHAR           = <any US-ASCII character (octets 0 - 127)>
      #
      #       CTL            = <any US-ASCII control character
      #                        (octets 0 - 31) and DEL (127)>
      #
      #       SP             = <US-ASCII SP, space (32)>
      #
      #       HT             = <US-ASCII HT, horizontal-tab (9)>
      #
      #       token          = 1*<any CHAR except CTLs or separators>
      #
      #       separators     = "(" | ")" | "<" | ">" | "@"
      #                      | "," | ";" | ":" | "\" | <">
      #                      | "/" | "[" | "]" | "?" | "="
      #                      | "{" | "}" | SP | HT
      #
      # Or, as redefined in RFC 7230:
      #
      #       token          = 1*tchar
      #
      #       tchar          = "!" / "#" / "$" / "%" / "&" / "'" / "*"
      #                      / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
      #                      / DIGIT / ALPHA
      #                      ; any VCHAR, except delimiters

      HEADER_LINE = /^([!#\$%&'\*\+\-\.\^_`\|~0-9a-z]+):\s*([\x20-\x7e]*?)\s*$/i

      attr_reader :headers

      def initialize
        @buffer  = []
        @env     = {}
        @headers = {}
        @stage   = 0
      end

      def complete?
        @stage == 2
      end

      def error?
        @stage == -1
      end

      def parse(chunk)
        chunk.each_byte do |octet|
          if octet == LF and @stage < 2
            @buffer.pop if @buffer.last == CR
            if @buffer.empty?
              complete if @stage == 1
            else
              result = case @stage
                       when 0 then start_line(string_buffer)
                       when 1 then header_line(string_buffer)
                       end

              if result
                @stage = 1
              else
                error
              end
            end
            @buffer = []
          else
            @buffer << octet if @stage >= 0
            error if @stage < 2 and @buffer.size > MAX_LINE_LENGTH
          end
        end
        @env['rack.input'] = StringIO.new(string_buffer)
      end

    private

      def complete
        @stage = 2
      end

      def error
        @stage = -1
      end

      def header_line(line)
        return false unless parsed = line.scan(HEADER_LINE).first

        key   = HTTP.normalize_header(parsed[0])
        value = parsed[1].strip

        if @headers.has_key?(key)
          @headers[key] << ', ' << value
        else
          @headers[key] = value
        end
        true
      end

      def string_buffer
        @buffer.pack('C*')
      end
    end

  end
end
