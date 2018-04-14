module ChunkyPNG
  class Canvas

    # Methods to save load a canvas from to stream, encoded in RGB, RGBA, BGR or ABGR format.
    module StreamExporting

      # Creates an RGB-formatted pixelstream with the pixel data from this canvas.
      #
      # Note that this format is fast but bloated, because no compression is used
      # and the internal representation is left intact. To reconstruct the
      # canvas, the width and height should be known.
      #
      # @return [String] The RGBA-formatted pixel data.
      def to_rgba_stream
        pixels.pack('N*')
      end

      # Creates an RGB-formatted pixelstream with the pixel data from this canvas.
      #
      # Note that this format is fast but bloated, because no compression is used
      # and the internal representation is almost left intact. To reconstruct
      # the canvas, the width and height should be known.
      #
      # @return [String] The RGB-formatted pixel data.
      def to_rgb_stream
        pixels.pack('NX' * pixels.length)
      end
      
      # Creates a stream of the alpha channel of this canvas.
      #
      # @return [String] The 0-255 alpha values of all pixels packed as string
      def to_alpha_channel_stream
        pixels.pack('C*')
      end

      # Creates a grayscale stream of this canvas.
      #
      # This method assume sthat this image is fully grayscale, i.e. R = G = B for
      # every pixel. The alpha channel will not be included in the stream.
      #
      # @return [String] The 0-255 grayscale values of all pixels packed as string.
      def to_grayscale_stream
        pixels.pack('nX' * pixels.length)
      end

      # Creates an ABGR-formatted pixelstream with the pixel data from this canvas.
      #
      # Note that this format is fast but bloated, because no compression is used
      # and the internal representation is left intact. To reconstruct the
      # canvas, the width and height should be known.
      #
      # @return [String] The RGBA-formatted pixel data.
      def to_abgr_stream
        pixels.pack('V*')
      end
    end
  end
end
