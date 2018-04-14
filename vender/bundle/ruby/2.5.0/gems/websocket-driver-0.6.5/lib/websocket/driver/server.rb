module WebSocket
  class Driver

    class Server < Driver
      EVENTS = %w[open message error close]

      def initialize(socket, options = {})
        super
        @http = HTTP::Request.new
        @delegate = nil
      end

      def env
        @http.complete? ? @http.env : nil
      end

      def url
        return nil unless e = env

        url  = "ws://#{e['HTTP_HOST']}"
        url << e['PATH_INFO']
        url << "?#{e['QUERY_STRING']}" unless e['QUERY_STRING'] == ''
        url
      end

      %w[add_extension set_header start frame text binary ping close].each do |method|
        define_method(method) do |*args, &block|
          if @delegate
            @delegate.__send__(method, *args, &block)
          else
            @queue << [method, args, block]
            true
          end
        end
      end

      %w[protocol version].each do |method|
        define_method(method) do
          @delegate && @delegate.__send__(method)
        end
      end

      def parse(chunk)
        return @delegate.parse(chunk) if @delegate

        @http.parse(chunk)
        return fail_request('Invalid HTTP request') if @http.error?
        return unless @http.complete?

        @delegate = Driver.rack(self, @options)
        open

        EVENTS.each do |event|
          @delegate.on(event) { |e| emit(event, e) }
        end

        emit(:connect, ConnectEvent.new)
      end

      def write(buffer)
        @socket.write(buffer)
      end

    private

      def fail_request(message)
        emit(:error, ProtocolError.new(message))
        emit(:close, CloseEvent.new(Hybi::ERRORS[:protocol_error], message))
      end

      def open
        @queue.each do |method, args, block|
          @delegate.__send__(method, *args, &block)
        end
        @queue = []
      end
    end

  end
end
