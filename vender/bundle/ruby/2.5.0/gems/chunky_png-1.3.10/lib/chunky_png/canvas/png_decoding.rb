module ChunkyPNG
  class Canvas

    # The PNGDecoding contains methods for decoding PNG datastreams to create a
    # Canvas object. The datastream can be provided as filename, string or IO
    # stream.
    #
    # Overview of the decoding process:
    #
    # * The optional PLTE and tRNS chunk are decoded for the color palette of
    #   the original image.
    # * The contents of the IDAT chunks is combined, and uncompressed using
    #   Inflate decompression to the image pixelstream.
    # * Based on the color mode, width and height of the original image, which
    #   is read from the PNG header (IHDR chunk), the amount of bytes
    #   per line is determined.
    # * For every line of pixels in the encoded image, the original byte values
    #   are restored by unapplying the milter method for that line.
    # * The read bytes are unfiltered given by the filter function specified by
    #   the first byte of the line.
    # * The unfiltered pixelstream are is into colored pixels, using the color mode.
    # * All lines combined to form the original image.
    #
    # For interlaced images, the original image was split into 7 subimages.
    # These images get decoded just like the process above (from step 3), and get
    # combined to form the original images.
    #
    # @see ChunkyPNG::Canvas::PNGEncoding
    # @see http://www.w3.org/TR/PNG/ The W3C PNG format specification
    module PNGDecoding

      # Decodes a Canvas from a PNG encoded string.
      # @param [String] str The string to read from.
      # @return [ChunkyPNG::Canvas] The canvas decoded from the PNG encoded string.
      def from_blob(str)
        from_datastream(ChunkyPNG::Datastream.from_blob(str))
      end

      alias_method :from_string, :from_blob

      # Decodes a Canvas from a PNG encoded file.
      # @param [String] filename The file to read from.
      # @return [ChunkyPNG::Canvas] The canvas decoded from the PNG file.
      def from_file(filename)
        from_datastream(ChunkyPNG::Datastream.from_file(filename))
      end

      # Decodes a Canvas from a PNG encoded stream.
      # @param [IO, #read] io The stream to read from.
      # @return [ChunkyPNG::Canvas] The canvas decoded from the PNG stream.
      def from_io(io)
        from_datastream(ChunkyPNG::Datastream.from_io(io))
      end

      alias_method :from_stream, :from_io

      # Decodes the Canvas from a PNG datastream instance.
      # @param [ChunkyPNG::Datastream] ds The datastream to decode.
      # @return [ChunkyPNG::Canvas] The canvas decoded from the PNG datastream.
      def from_datastream(ds)
        width      = ds.header_chunk.width
        height     = ds.header_chunk.height
        color_mode = ds.header_chunk.color
        interlace  = ds.header_chunk.interlace
        depth      = ds.header_chunk.depth

        if width == 0 || height == 0
          raise ExpectationFailed, "Invalid image size, width: #{width}, height: #{height}"
        end

        decoding_palette, transparent_color = nil, nil
        case color_mode
          when ChunkyPNG::COLOR_INDEXED
            decoding_palette = ChunkyPNG::Palette.from_chunks(ds.palette_chunk, ds.transparency_chunk)
          when ChunkyPNG::COLOR_TRUECOLOR
            transparent_color = ds.transparency_chunk.truecolor_entry(depth) if ds.transparency_chunk
          when ChunkyPNG::COLOR_GRAYSCALE
            transparent_color = ds.transparency_chunk.grayscale_entry(depth) if ds.transparency_chunk
        end

        decode_png_pixelstream(ds.imagedata, width, height, color_mode, depth, interlace, decoding_palette, transparent_color)
      end

      # Decodes a canvas from a PNG encoded pixelstream, using a given width, height,
      # color mode and interlacing mode.
      # @param [String] stream The pixelstream to read from.
      # @param [Integer] width The width of the image.
      # @param [Integer] width The height of the image.
      # @param [Integer] color_mode The color mode of the encoded pixelstream.
      # @param [Integer] depth The bit depth of the pixel samples.
      # @param [Integer] interlace The interlace method of the encoded pixelstream.
      # @param [ChunkyPNG::Palette] decoding_palette The palette to use to decode colors.
      # @param [Integer] transparent_color The color that should be considered fully transparent.
      # @return [ChunkyPNG::Canvas] The decoded Canvas instance.
      def decode_png_pixelstream(stream, width, height, color_mode, depth, interlace, decoding_palette, transparent_color)
        raise ChunkyPNG::ExpectationFailed, "This palette is not suitable for decoding!" if decoding_palette && !decoding_palette.can_decode?

        image = case interlace
          when ChunkyPNG::INTERLACING_NONE;  decode_png_without_interlacing(stream, width, height, color_mode, depth, decoding_palette)
          when ChunkyPNG::INTERLACING_ADAM7; decode_png_with_adam7_interlacing(stream, width, height, color_mode, depth, decoding_palette)
          else raise ChunkyPNG::NotSupported, "Don't know how the handle interlacing method #{interlace}!"
        end

        image.pixels.map! { |c| c == transparent_color ? ChunkyPNG::Color::TRANSPARENT : c } if transparent_color
        return image
      end

      protected

      # Decodes a canvas from a non-interlaced PNG encoded pixelstream, using a
      # given width, height and color mode.
      # @param stream (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param width (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param height (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param color_mode (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param depth (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param [ChunkyPNG::Palette] decoding_palette The palette to use to decode colors.
      # @return (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      def decode_png_without_interlacing(stream, width, height, color_mode, depth, decoding_palette)
        decode_png_image_pass(stream, width, height, color_mode, depth, 0, decoding_palette)
      end

      # Decodes a canvas from a Adam 7 interlaced PNG encoded pixelstream, using a
      # given width, height and color mode.
      # @param stream (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param width (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param height (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param color_mode (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param depth (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param [ChunkyPNG::Palette] decoding_palette The palette to use to decode colors.
      # @return (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      def decode_png_with_adam7_interlacing(stream, width, height, color_mode, depth, decoding_palette)
        canvas = new(width, height)
        start_pos = 0
        for pass in 0...7
          sm_width, sm_height = adam7_pass_size(pass, width, height)
          sm = decode_png_image_pass(stream, sm_width, sm_height, color_mode, depth, start_pos, decoding_palette)
          adam7_merge_pass(pass, canvas, sm)
          start_pos += ChunkyPNG::Color.pass_bytesize(color_mode, depth, sm_width, sm_height)
        end
        canvas
      end

      # Extract 4 consecutive bits from a byte.
      # @param [Integer] byte The byte (0..255) value to extract a 4 bit value from.
      # @param [Integer] index The index within the byte. This should be either 0 or 2;
      #        the value will be modded by 2 to enforce this.
      # @return [Integer] The extracted 4bit value (0..15)
      def decode_png_extract_4bit_value(byte, index)
        (index & 0x01 == 0) ? ((byte & 0xf0) >> 4) : (byte & 0x0f)
      end

      # Extract 2 consecutive bits from a byte.
      # @param [Integer] byte The byte (0..255) value to extract a 2 bit value from.
      # @param [Integer] index The index within the byte. This should be either 0, 1, 2, or 3;
      #        the value will be modded by 4 to enforce this.
      # @return [Integer] The extracted 2 bit value (0..3)
      def decode_png_extract_2bit_value(byte, index)
        bitshift = 6 - ((index & 0x03) << 1)
        (byte & (0x03 << bitshift)) >> bitshift
      end

      # Extract a bit from a byte on a given index.
      # @param [Integer] byte The byte (0..255) value to extract a bit from.
      # @param [Integer] index The index within the byte. This should be 0..7;
      #        the value will be modded by 8 to enforce this.
      # @return [Integer] Either 1 or 0.
      def decode_png_extract_1bit_value(byte, index)
        bitshift = 7 - (index & 0x07)
        (byte & (0x01 << bitshift)) >> bitshift
      end

      # Resamples a 16 bit value to an 8 bit value. This will discard some color information.
      # @param [Integer] value The 16 bit value to resample.
      # @return [Integer] The 8 bit resampled value
      def decode_png_resample_16bit_value(value)
        value >> 8
      end

      # No-op - available for completeness sake only
      # @param [Integer] value The 8 bit value to resample.
      # @return [Integer] The 8 bit resampled value
      def decode_png_resample_8bit_value(value)
        value
      end

      # Resamples a 4 bit value to an 8 bit value.
      # @param [Integer] value The 4 bit value to resample.
      # @return [Integer] The 8 bit resampled value.
      def decode_png_resample_4bit_value(value)
        value << 4 | value
      end

      # Resamples a 2 bit value to an 8 bit value.
      # @param [Integer] value The 2 bit value to resample.
      # @return [Integer] The 8 bit resampled value.
      def decode_png_resample_2bit_value(value)
        value << 6 | value << 4 | value << 2 | value
      end

      # Resamples a 1 bit value to an 8 bit value.
      # @param [Integer] value The 1 bit value to resample.
      # @return [Integer] The 8 bit resampled value
      def decode_png_resample_1bit_value(value)
        value == 0x01 ? 0xff : 0x00
      end


      # Decodes a scanline of a 1-bit, indexed image into a row of pixels.
      # @param [String] stream The stream to decode from.
      # @param [Integer] pos The position in the stream on which the scanline starts (including the filter byte).
      # @param [Integer] width The width in pixels of the scanline.
      # @param [ChunkyPNG::Palette] decoding_palette The palette to use to decode colors.
      # @return [Array<Integer>] An array of decoded pixels.
      def decode_png_pixels_from_scanline_indexed_1bit(stream, pos, width, decoding_palette)
        (0...width).map do |index|
          palette_pos = decode_png_extract_1bit_value(stream.getbyte(pos + 1 + (index >> 3)), index)
          decoding_palette[palette_pos]
        end
      end

      # Decodes a scanline of a 2-bit, indexed image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_indexed_2bit(stream, pos, width, decoding_palette)
        (0...width).map do |index|
          palette_pos = decode_png_extract_2bit_value(stream.getbyte(pos + 1 + (index >> 2)), index)
          decoding_palette[palette_pos]
        end
      end

      # Decodes a scanline of a 4-bit, indexed image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_indexed_4bit(stream, pos, width, decoding_palette)
        (0...width).map do |index|
          palette_pos = decode_png_extract_4bit_value(stream.getbyte(pos + 1 + (index >> 1)), index)
          decoding_palette[palette_pos]
        end
      end

      # Decodes a scanline of a 8-bit, indexed image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_indexed_8bit(stream, pos, width, decoding_palette)
        (1..width).map { |i| decoding_palette[stream.getbyte(pos + i)] }
      end

      # Decodes a scanline of an 8-bit, true color image with transparency into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_truecolor_alpha_8bit(stream, pos, width, _decoding_palette)
        stream.unpack("@#{pos + 1}N#{width}")
      end

      # Decodes a scanline of a 16-bit, true color image with transparency into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_truecolor_alpha_16bit(stream, pos, width, _decoding_palette)
        pixels = []
        stream.unpack("@#{pos + 1}n#{width * 4}").each_slice(4) do |r, g, b, a|
          pixels << ChunkyPNG::Color.rgba(decode_png_resample_16bit_value(r), decode_png_resample_16bit_value(g),
                                          decode_png_resample_16bit_value(b), decode_png_resample_16bit_value(a))
        end
        return pixels
      end

      # Decodes a scanline of an 8-bit, true color image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_truecolor_8bit(stream, pos, width, _decoding_palette)
        stream.unpack("@#{pos + 1}" << ('NX' * width)).map { |c| c | 0x000000ff }
      end

      # Decodes a scanline of a 16-bit, true color image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_truecolor_16bit(stream, pos, width, _decoding_palette)
        pixels = []
        stream.unpack("@#{pos + 1}n#{width * 3}").each_slice(3) do |r, g, b|
          pixels << ChunkyPNG::Color.rgb(decode_png_resample_16bit_value(r), decode_png_resample_16bit_value(g), decode_png_resample_16bit_value(b))
        end
        return pixels
      end

      # Decodes a scanline of an 8-bit, grayscale image with transparency into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_alpha_8bit(stream, pos, width, _decoding_palette)
        (0...width).map { |i| ChunkyPNG::Color.grayscale_alpha(stream.getbyte(pos + (i * 2) + 1), stream.getbyte(pos + (i * 2) + 2)) }
      end

      # Decodes a scanline of a 16-bit, grayscale image with transparency into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_alpha_16bit(stream, pos, width, _decoding_palette)
        pixels = []
        stream.unpack("@#{pos + 1}n#{width * 2}").each_slice(2) do |g, a|
          pixels << ChunkyPNG::Color.grayscale_alpha(decode_png_resample_16bit_value(g), decode_png_resample_16bit_value(a))
        end
        return pixels
      end

      # Decodes a scanline of a 1-bit, grayscale image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_1bit(stream, pos, width, _decoding_palette)
        (0...width).map do |index|
          value = decode_png_extract_1bit_value(stream.getbyte(pos + 1 + (index >> 3)), index)
          value == 1 ? ChunkyPNG::Color::WHITE : ChunkyPNG::Color::BLACK
        end
      end

      # Decodes a scanline of a 2-bit, grayscale image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_2bit(stream, pos, width, _decoding_palette)
        (0...width).map do |index|
          value = decode_png_extract_2bit_value(stream.getbyte(pos + 1 + (index >> 2)), index)
          ChunkyPNG::Color.grayscale(decode_png_resample_2bit_value(value))
        end
      end

      # Decodes a scanline of a 4-bit, grayscale image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_4bit(stream, pos, width, _decoding_palette)
        (0...width).map do |index|
          value = decode_png_extract_4bit_value(stream.getbyte(pos + 1 + (index >> 1)), index)
          ChunkyPNG::Color.grayscale(decode_png_resample_4bit_value(value))
        end
      end

      # Decodes a scanline of an 8-bit, grayscale image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_8bit(stream, pos, width, _decoding_palette)
        (1..width).map { |i| ChunkyPNG::Color.grayscale(stream.getbyte(pos + i)) }
      end

      # Decodes a scanline of a 16-bit, grayscale image into a row of pixels.
      # @params (see #decode_png_pixels_from_scanline_indexed_1bit)
      # @return (see #decode_png_pixels_from_scanline_indexed_1bit)
      def decode_png_pixels_from_scanline_grayscale_16bit(stream, pos, width, _decoding_palette)
        values = stream.unpack("@#{pos + 1}n#{width}")
        values.map { |value| ChunkyPNG::Color.grayscale(decode_png_resample_16bit_value(value)) }
      end

      # Returns the method name to use to decode scanlines into pixels.
      # @param [Integer] color_mode The color mode of the image.
      # @param [Integer] depth The bit depth of the image.
      # @return [Symbol] The method name to use for decoding, to be called on the canvas class.
      # @raise [ChunkyPNG::NotSupported] when the color_mode and/or bit depth is not supported.
      def decode_png_pixels_from_scanline_method(color_mode, depth)
        decoder_method = case color_mode
          when ChunkyPNG::COLOR_TRUECOLOR;       :"decode_png_pixels_from_scanline_truecolor_#{depth}bit"
          when ChunkyPNG::COLOR_TRUECOLOR_ALPHA; :"decode_png_pixels_from_scanline_truecolor_alpha_#{depth}bit"
          when ChunkyPNG::COLOR_INDEXED;         :"decode_png_pixels_from_scanline_indexed_#{depth}bit"
          when ChunkyPNG::COLOR_GRAYSCALE;       :"decode_png_pixels_from_scanline_grayscale_#{depth}bit"
          when ChunkyPNG::COLOR_GRAYSCALE_ALPHA; :"decode_png_pixels_from_scanline_grayscale_alpha_#{depth}bit"
          else nil
        end

        raise ChunkyPNG::NotSupported, "No decoder found for color mode #{color_mode} and #{depth}-bit depth!" unless respond_to?(decoder_method, true)
        decoder_method
      end

      # Decodes a single PNG image pass width a given width, height and color
      # mode, to a Canvas, starting at the given position in the stream.
      #
      # A non-interlaced image only consists of one pass, while an Adam7
      # image consists of 7 passes that must be combined after decoding.
      #
      # @param stream (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param width (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param height (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param color_mode (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      # @param [Integer] start_pos The position in the pixel stream to start reading.
      # @param [ChunkyPNG::Palette] decoding_palette The palette to use to decode colors.
      # @return (see ChunkyPNG::Canvas::PNGDecoding#decode_png_pixelstream)
      def decode_png_image_pass(stream, width, height, color_mode, depth, start_pos, decoding_palette)

        pixels = []
        if width > 0 && height > 0

          stream << ChunkyPNG::EXTRA_BYTE if color_mode == ChunkyPNG::COLOR_TRUECOLOR
          pixel_decoder = decode_png_pixels_from_scanline_method(color_mode, depth)
          line_length   = ChunkyPNG::Color.scanline_bytesize(color_mode, depth, width)
          pixel_size    = ChunkyPNG::Color.pixel_bytesize(color_mode, depth)

          raise ChunkyPNG::ExpectationFailed, "Invalid stream length!" unless stream.bytesize - start_pos >= ChunkyPNG::Color.pass_bytesize(color_mode, depth, width, height)

          pos, prev_pos = start_pos, nil
          for _ in 0...height do
            decode_png_str_scanline(stream, pos, prev_pos, line_length, pixel_size)
            pixels.concat(send(pixel_decoder, stream, pos, width, decoding_palette))

            prev_pos = pos
            pos += line_length + 1
          end
        end

        new(width, height, pixels)
      end

      # Decodes a scanline if it was encoded using filtering.
      #
      # It will extract the filtering method from the first byte of the scanline, and uses the
      # method to change the subsequent bytes to unfiltered values. This will modify the pixelstream.
      #
      # The bytes of the scanline can then be used to construct pixels, based on the color mode..
      #
      # @param [String] stream The pixelstream to undo the filtering in.
      # @param [Integer] pos The starting position of the scanline to decode.
      # @param [Integer, nil] prev_pos The starting position of the previously decoded scanline, or <tt>nil</tt>
      #     if this is the first scanline of the image.
      # @param [Integer] line_length The number of bytes in the scanline, discounting the filter method byte.
      # @param [Integer] pixel_size The number of bytes used per pixel, based on the color mode.
      # @return [void]
      def decode_png_str_scanline(stream, pos, prev_pos, line_length, pixel_size)
        case stream.getbyte(pos)
          when ChunkyPNG::FILTER_NONE;    # noop
          when ChunkyPNG::FILTER_SUB;     decode_png_str_scanline_sub(     stream, pos, prev_pos, line_length, pixel_size)
          when ChunkyPNG::FILTER_UP;      decode_png_str_scanline_up(      stream, pos, prev_pos, line_length, pixel_size)
          when ChunkyPNG::FILTER_AVERAGE; decode_png_str_scanline_average( stream, pos, prev_pos, line_length, pixel_size)
          when ChunkyPNG::FILTER_PAETH;   decode_png_str_scanline_paeth(   stream, pos, prev_pos, line_length, pixel_size)
          else raise ChunkyPNG::NotSupported, "Unknown filter type: #{stream.getbyte(pos)}!"
        end
      end

      # Decodes a scanline that wasn't encoded using filtering. This is a no-op.
      # @params (see #decode_png_str_scanline)
      # @return [void]
      def decode_png_str_scanline_sub_none(stream, pos, prev_pos, line_length, pixel_size)
        # noop - this method shouldn't get called.
      end

      # Decodes a scanline in a pixelstream that was encoded using SUB filtering.
      # This will change the pixelstream to have unfiltered values.
      # @params (see #decode_png_str_scanline)
      # @return [void]
      def decode_png_str_scanline_sub(stream, pos, prev_pos, line_length, pixel_size)
        for i in 1..line_length do
          stream.setbyte(pos + i, (stream.getbyte(pos + i) + (i > pixel_size ? stream.getbyte(pos + i - pixel_size) : 0)) & 0xff)
        end
      end

      # Decodes a scanline in a pixelstream that was encoded using UP filtering.
      # This will change the pixelstream to have unfiltered values.
      # @params (see #decode_png_str_scanline)
      # @return [void]
      def decode_png_str_scanline_up(stream, pos, prev_pos, line_length, pixel_size)
        for i in 1..line_length do
          up = prev_pos ? stream.getbyte(prev_pos + i) : 0
          stream.setbyte(pos + i, (stream.getbyte(pos + i) + up) & 0xff)
        end
      end

      # Decodes a scanline in a pixelstream that was encoded using AVERAGE filtering.
      # This will change the pixelstream to have unfiltered values.
      # @params (see #decode_png_str_scanline)
      # @return [void]
      def decode_png_str_scanline_average(stream, pos, prev_pos, line_length, pixel_size)
        for i in 1..line_length do
          a = (i > pixel_size) ? stream.getbyte(pos + i - pixel_size) : 0
          b = prev_pos ? stream.getbyte(prev_pos + i) : 0
          stream.setbyte(pos + i, (stream.getbyte(pos + i) + ((a + b) >> 1)) & 0xff)
        end
      end

      # Decodes a scanline in a pixelstream that was encoded using PAETH filtering.
      # This will change the pixelstream to have unfiltered values.
      # @params (see #decode_png_str_scanline)
      # @return [void]
      def decode_png_str_scanline_paeth(stream, pos, prev_pos, line_length, pixel_size)
        for i in 1..line_length do
          cur_pos = pos + i
          a = (i > pixel_size) ? stream.getbyte(cur_pos - pixel_size) : 0
          b = prev_pos ? stream.getbyte(prev_pos + i) : 0
          c = (prev_pos && i > pixel_size) ? stream.getbyte(prev_pos + i - pixel_size) : 0
          p = a + b - c
          pa = (p - a).abs
          pb = (p - b).abs
          pc = (p - c).abs
          pr = (pa <= pb) ? (pa <= pc ? a : c) : (pb <= pc ? b : c)
          stream.setbyte(cur_pos, (stream.getbyte(cur_pos) + pr) & 0xff)
        end
      end
    end
  end
end
