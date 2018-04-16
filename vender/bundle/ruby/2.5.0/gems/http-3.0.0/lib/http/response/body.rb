# frozen_string_literal: true

require "forwardable"
require "http/client"

module HTTP
  class Response
    # A streamable response body, also easily converted into a string
    class Body
      extend Forwardable
      include Enumerable
      def_delegator :to_s, :empty?

      # The connection object used to make the corresponding request.
      #
      # @return [HTTP::Connection]
      attr_reader :connection

      def initialize(stream, encoding: Encoding::BINARY)
        @stream     = stream
        @connection = stream.is_a?(Inflater) ? stream.connection : stream
        @streaming  = nil
        @contents   = nil
        @encoding   = find_encoding(encoding)
      end

      # (see HTTP::Client#readpartial)
      def readpartial(*args)
        stream!
        chunk = @stream.readpartial(*args)
        chunk.force_encoding(@encoding) if chunk
      end

      # Iterate over the body, allowing it to be enumerable
      def each
        while (chunk = readpartial)
          yield chunk
        end
      end

      # @return [String] eagerly consume the entire body as a string
      def to_s
        return @contents if @contents

        raise StateError, "body is being streamed" unless @streaming.nil?

        begin
          @streaming  = false
          @contents   = String.new("").force_encoding(@encoding)

          while (chunk = @stream.readpartial)
            @contents << chunk.force_encoding(@encoding)
          end
        rescue
          @contents = nil
          raise
        end

        @contents
      end
      alias to_str to_s

      # Assert that the body is actively being streamed
      def stream!
        raise StateError, "body has already been consumed" if @streaming == false
        @streaming = true
      end

      # Easier to interpret string inspect
      def inspect
        "#<#{self.class}:#{object_id.to_s(16)} @streaming=#{!!@streaming}>"
      end

      private

      # Retrieve encoding by name. If encoding cannot be found, default to binary.
      def find_encoding(encoding)
        Encoding.find encoding
      rescue ArgumentError
        Encoding::BINARY
      end
    end
  end
end
