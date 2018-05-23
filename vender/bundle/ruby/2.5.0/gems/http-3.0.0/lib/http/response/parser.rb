# frozen_string_literal: true

module HTTP
  class Response
    class Parser
      attr_reader :headers

      def initialize
        @parser = HTTP::Parser.new(self)
        reset
      end

      def add(data)
        @parser << data
      end
      alias << add

      def headers?
        !!@headers
      end

      def http_version
        @parser.http_version.join(".")
      end

      def status_code
        @parser.status_code
      end

      #
      # HTTP::Parser callbacks
      #

      def on_headers_complete(headers)
        @headers = headers
      end

      def on_body(chunk)
        if @chunk
          @chunk << chunk
        else
          @chunk = chunk
        end
      end

      def chunk
        chunk  = @chunk
        @chunk = nil
        chunk
      end

      def on_message_complete
        @finished = true
      end

      def reset
        @parser.reset!

        @finished = false
        @headers  = nil
        @chunk    = nil
      end

      def finished?
        @finished
      end
    end
  end
end
