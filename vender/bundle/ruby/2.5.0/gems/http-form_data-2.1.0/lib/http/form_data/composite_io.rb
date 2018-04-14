# frozen_string_literal: true

require "stringio"

module HTTP
  module FormData
    # Provides IO interface across multiple IO objects.
    class CompositeIO
      # @param [Array<IO>] ios Array of IO objects
      def initialize(ios)
        @index  = 0
        @buffer = "".b
        @ios    = ios.map do |io|
          if io.is_a?(String)
            StringIO.new(io)
          elsif io.respond_to?(:read)
            io
          else
            raise ArgumentError,
              "#{io.inspect} is neither a String nor an IO object"
          end
        end
      end

      # Reads and returns partial content acrosss multiple IO objects.
      #
      # @param [Integer] length Number of bytes to retrieve
      # @param [String] outbuf String to be replaced with retrieved data
      #
      # @return [String, nil]
      def read(length = nil, outbuf = nil)
        outbuf = outbuf.to_s.clear
        # buffer in JRuby is sometimes US-ASCII, force to ASCII-8BIT
        outbuf.force_encoding(Encoding::BINARY)

        while current_io
          current_io.read(length, @buffer)
          outbuf << @buffer.force_encoding(Encoding::BINARY)

          if length
            length -= @buffer.bytesize
            break if length.zero?
          end

          advance_io
        end

        outbuf unless length && outbuf.empty?
      end

      # Returns sum of all IO sizes.
      def size
        @size ||= @ios.map(&:size).inject(0, :+)
      end

      # Rewinds all IO objects and set cursor to the first IO object.
      def rewind
        @ios.each(&:rewind)
        @index = 0
      end

      private

      # Returns IO object under the cursor.
      def current_io
        @ios[@index]
      end

      # Advances cursor to the next IO object.
      def advance_io
        @index += 1
      end
    end
  end
end
