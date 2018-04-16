# frozen_string_literal: true

module HTTP
  module FormData
    # Common behaviour for objects defined by an IO object.
    module Readable
      # Returns IO content.
      #
      # @return [String]
      def to_s
        rewind
        content = read
        rewind
        content
      end

      # Reads and returns part of IO content.
      #
      # @param [Integer] length Number of bytes to retrieve
      # @param [String] outbuf String to be replaced with retrieved data
      #
      # @return [String, nil]
      def read(length = nil, outbuf = nil)
        @io.read(length, outbuf)
      end

      # Returns IO size.
      #
      # @return [Integer]
      def size
        @io.size
      end

      # Rewinds the IO.
      def rewind
        @io.rewind
      end
    end
  end
end
