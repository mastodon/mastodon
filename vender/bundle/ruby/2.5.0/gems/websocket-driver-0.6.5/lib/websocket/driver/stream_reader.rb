module WebSocket
  class Driver

    class StreamReader
      # Try to minimise the number of reallocations done:
      MINIMUM_AUTOMATIC_PRUNE_OFFSET = 128

      def initialize
        @buffer = String.new('').force_encoding(BINARY)
        @offset = 0
      end

      def put(chunk)
        return unless chunk and chunk.bytesize > 0
        @buffer << chunk.force_encoding(BINARY)
      end

      # Read bytes from the data:
      def read(length)
        return nil if (@offset + length) > @buffer.bytesize

        chunk = @buffer.byteslice(@offset, length)
        @offset += chunk.bytesize

        prune if @offset > MINIMUM_AUTOMATIC_PRUNE_OFFSET

        return chunk
      end

      def each_byte
        prune

        @buffer.each_byte do |octet|
          @offset += 1
          yield octet
        end
      end

    private

      def prune
        buffer_size = @buffer.bytesize

        if @offset > buffer_size
          @buffer = String.new('').force_encoding(BINARY)
        else
          @buffer = @buffer.byteslice(@offset, buffer_size - @offset)
        end

        @offset = 0
      end
    end

  end
end
