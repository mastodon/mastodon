module ChunkyPNG
  class Canvas

    # Methods to quickly load a canvas from a stream, encoded in RGB, RGBA, BGR or ABGR format.
    module StreamImporting

      # Creates a canvas by reading pixels from an RGB formatted stream with a
      # provided with and height.
      #
      # Every pixel should be represented by 3 bytes in the stream, in the correct
      # RGB order. This format closely resembles the internal representation of a
      # canvas object, so this kind of stream can be read extremely quickly.
      #
      # @param [Integer] width The width of the new canvas.
      # @param [Integer] height The height of the new canvas.
      # @param [#read, String] stream The stream to read the pixel data from.
      # @return [ChunkyPNG::Canvas] The newly constructed canvas instance.
      def from_rgb_stream(width, height, stream)
        string = stream.respond_to?(:read) ? stream.read(3 * width * height) : stream.to_s[0, 3 * width * height]
        string << ChunkyPNG::EXTRA_BYTE # Add a fourth byte to the last RGB triple.
        unpacker = 'NX' * (width * height)
        pixels = string.unpack(unpacker).map { |color| color | 0x000000ff }
        self.new(width, height, pixels)
      end

      # Creates a canvas by reading pixels from an RGBA formatted stream with a
      # provided with and height.
      #
      # Every pixel should be represented by 4 bytes in the stream, in the correct
      # RGBA order. This format is exactly like the internal representation of a
      # canvas object, so this kind of stream can be read extremely quickly.
      #
      # @param [Integer] width The width of the new canvas.
      # @param [Integer] height The height of the new canvas.
      # @param [#read, String] stream The stream to read the pixel data from.
      # @return [ChunkyPNG::Canvas] The newly constructed canvas instance.
      def from_rgba_stream(width, height, stream)
        string = stream.respond_to?(:read) ? stream.read(4 * width * height) : stream.to_s[0, 4 * width * height]
        self.new(width, height, string.unpack("N*"))
      end

      # Creates a canvas by reading pixels from an BGR formatted stream with a
      # provided with and height.
      #
      # Every pixel should be represented by 3 bytes in the stream, in the correct
      # BGR order. This format closely resembles the internal representation of a
      # canvas object, so this kind of stream can be read extremely quickly.
      #
      # @param [Integer] width The width of the new canvas.
      # @param [Integer] height The height of the new canvas.
      # @param [#read, String] stream The stream to read the pixel data from.
      # @return [ChunkyPNG::Canvas] The newly constructed canvas instance.
      def from_bgr_stream(width, height, stream)
        string = ChunkyPNG::EXTRA_BYTE.dup # Add a first byte to the first BGR triple.
        string << (stream.respond_to?(:read) ? stream.read(3 * width * height) : stream.to_s[0, 3 * width * height])
        pixels = string.unpack("@1" << ('XV' * (width * height))).map { |color| color | 0x000000ff }
        self.new(width, height, pixels)
      end

      # Creates a canvas by reading pixels from an ARGB formatted stream with a
      # provided with and height.
      #
      # Every pixel should be represented by 4 bytes in the stream, in the correct
      # ARGB order. This format is almost like the internal representation of a
      # canvas object, so this kind of stream can be read extremely quickly.
      #
      # @param [Integer] width The width of the new canvas.
      # @param [Integer] height The height of the new canvas.
      # @param [#read, String] stream The stream to read the pixel data from.
      # @return [ChunkyPNG::Canvas] The newly constructed canvas instance.
      def from_abgr_stream(width, height, stream)
        string = stream.respond_to?(:read) ? stream.read(4 * width * height) : stream.to_s[0, 4 * width * height]
        self.new(width, height, string.unpack("V*"))
      end
    end
  end
end
