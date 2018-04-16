module WebSocket
  module HTTP

    class Request
      include Headers

      REQUEST_LINE     = /^(OPTIONS|GET|HEAD|POST|PUT|DELETE|TRACE|CONNECT) ([\x21-\x7e]+) (HTTP\/[0-9]+\.[0-9]+)$/
      REQUEST_TARGET   = /^(.*?)(\?(.*))?$/
      RESERVED_HEADERS = %w[content-length content-type]

      attr_reader :env

    private

      def start_line(line)
        return false unless parsed = line.scan(REQUEST_LINE).first

        target = parsed[1].scan(REQUEST_TARGET).first

        @env = {
          'REQUEST_METHOD' => parsed[0],
          'SCRIPT_NAME'    => '',
          'PATH_INFO'      => target[0],
          'QUERY_STRING'   => target[2] || ''
        }
        true
      end

      def complete
        super
        @headers.each do |name, value|
          rack_name = name.upcase.gsub(/-/, '_')
          rack_name = "HTTP_#{rack_name}" unless RESERVED_HEADERS.include?(name)
          @env[rack_name] = value
        end
        if host = @env['HTTP_HOST']
          uri = URI.parse("http://#{host}")
          @env['SERVER_NAME'] = uri.host
          @env['SERVER_PORT'] = uri.port.to_s
        end
      end
    end

  end
end
