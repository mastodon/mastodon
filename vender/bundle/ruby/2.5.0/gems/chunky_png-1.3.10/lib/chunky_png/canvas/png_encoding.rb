module ChunkyPNG
  class Canvas
    
    # Methods for encoding a Canvas instance into a PNG datastream.
    #
    # Overview of the encoding process:
    #
    # * The image is split up in scanlines (i.e. rows of pixels);
    # * All pixels are encoded as a pixelstream, based on the color mode.
    # * All the pixel bytes in the pixelstream are adjusted using a filtering 
    #   method if one is specified.
    # * Compress the resulting string using deflate compression.
    # * Split compressed data over one or more PNG chunks.
    # * These chunks should be embedded in a datastream with at least a IHDR and 
    #   IEND chunk and possibly a PLTE chunk.
    #
    # For interlaced images, the initial image is first split into 7 subimages.
    # These images get encoded exactly as above, and the result gets combined
    # before the compression step.
    #
    # @see ChunkyPNG::Canvas::PNGDecoding
    # @see http://www.w3.org/TR/PNG/ The W3C PNG format specification
    module PNGEncoding

      # The palette used for encoding the image.This is only in used for images
      # that get encoded using indexed colors.
      # @return [ChunkyPNG::Palette]
      attr_accessor :encoding_palette

      # Writes the canvas to an IO stream, encoded as a PNG image.
      # @param [IO] io The output stream to write to.
      # @param constraints (see ChunkyPNG::Canvas::PNGEncoding#to_datastream)
      # @return [void]
      def write(io, constraints = {})
        to_datastream(constraints).write(io)
      end

      # Writes the canvas to a file, encoded as a PNG image.
      # @param [String] filename The file to save the PNG image to.
      # @param constraints (see ChunkyPNG::Canvas::PNGEncoding#to_datastream)
      # @return [void]
      def save(filename, constraints = {})
        File.open(filename, 'wb') { |io| write(io, constraints) }
      end
      
      # Encoded the canvas to a PNG formatted string.
      # @param constraints (see ChunkyPNG::Canvas::PNGEncoding#to_datastream)
      # @return [String] The PNG encoded canvas as string.
      def to_blob(constraints = {})
        to_datastream(constraints).to_blob
      end
      
      alias_method :to_string, :to_blob
      alias_method :to_s, :to_blob

      # Converts this Canvas to a datastream, so that it can be saved as a PNG image.
      # @param [Hash, Symbol] constraints The constraints to use when encoding the canvas.
      #    This can either be a hash with different constraints, or a symbol which acts as a 
      #    preset for some constraints. If no constraints are given, ChunkyPNG will decide  
      #    for itself how to best create the PNG datastream. 
      #    Supported presets are <tt>:fast_rgba</tt> for quickly saving images with transparency,
      #    <tt>:fast_rgb</tt> for quickly saving opaque images, and <tt>:best_compression</tt> to
      #    obtain the smallest possible filesize.
      # @option constraints [Fixnum] :color_mode The color mode to use. Use one of the 
      #    ChunkyPNG::COLOR_* constants.
      # @option constraints [true, false] :interlace Whether to use interlacing.
      # @option constraints [Fixnum] :compression The compression level for Zlib. This can be a
      #    value between 0 and 9, or a Zlib constant like Zlib::BEST_COMPRESSION.
      # @option constraints [Fixnum] :bit_depth The bit depth to use. This option is only used
      #    for indexed images, in which case it overrides the determined minimal bit depth. For
      #    all the other color modes, a bit depth of 8 is used.
      # @return [ChunkyPNG::Datastream] The PNG datastream containing the encoded canvas.
      # @see ChunkyPNG::Canvas::PNGEncoding#determine_png_encoding
      def to_datastream(constraints = {})
        encoding = determine_png_encoding(constraints)

        ds = Datastream.new
        ds.header_chunk = Chunk::Header.new(:width => width, :height => height,
            :color => encoding[:color_mode], :depth => encoding[:bit_depth], :interlace => encoding[:interlace])

        if encoding[:color_mode] == ChunkyPNG::COLOR_INDEXED
          ds.palette_chunk      = encoding_palette.to_plte_chunk
          ds.transparency_chunk = encoding_palette.to_trns_chunk unless encoding_palette.opaque?
        end
        data           = encode_png_pixelstream(encoding[:color_mode], encoding[:bit_depth], encoding[:interlace], encoding[:filtering])
        ds.data_chunks = Chunk::ImageData.split_in_chunks(data, encoding[:compression])
        ds.end_chunk   = Chunk::End.new
        return ds
      end

      protected

      # Determines the best possible PNG encoding variables for this image, by analyzing 
      # the colors used for the image.
      #
      # You can provide constraints for the encoding variables by passing a hash with 
      # encoding variables to this method.
      #
      # @param [Hash, Symbol] constraints The constraints for the encoding. This can be a
      #    Hash or a preset symbol.
      # @return [Hash] A hash with encoding options for {ChunkyPNG::Canvas::PNGEncoding#to_datastream}
      def determine_png_encoding(constraints = {})

        encoding = case constraints
          when :fast_rgb;         { :color_mode => ChunkyPNG::COLOR_TRUECOLOR, :compression => Zlib::BEST_SPEED }
          when :fast_rgba;        { :color_mode => ChunkyPNG::COLOR_TRUECOLOR_ALPHA, :compression => Zlib::BEST_SPEED }
          when :best_compression; { :compression => Zlib::BEST_COMPRESSION, :filtering => ChunkyPNG::FILTER_PAETH }
          when :good_compression; { :compression => Zlib::BEST_COMPRESSION, :filtering => ChunkyPNG::FILTER_NONE }
          when :no_compression;   { :compression => Zlib::NO_COMPRESSION }
          when :black_and_white;  { :color_mode => ChunkyPNG::COLOR_GRAYSCALE, :bit_depth => 1 } 
          when Hash; constraints
          else raise ChunkyPNG::Exception, "Unknown encoding preset: #{constraints.inspect}"
        end

        # Do not create a palette when the encoding is given and does not require a palette.
        if encoding[:color_mode]
          if encoding[:color_mode] == ChunkyPNG::COLOR_INDEXED
            self.encoding_palette = self.palette
            encoding[:bit_depth] ||= self.encoding_palette.determine_bit_depth
          else
            encoding[:bit_depth] ||= 8
          end
        else
          self.encoding_palette = self.palette
          suggested_color_mode, suggested_bit_depth = encoding_palette.best_color_settings
          encoding[:color_mode] ||= suggested_color_mode
          encoding[:bit_depth]  ||= suggested_bit_depth
        end

        # Use Zlib's default for compression unless otherwise provided.
        encoding[:compression] ||= Zlib::DEFAULT_COMPRESSION

        encoding[:interlace] = case encoding[:interlace]
          when nil, false, ChunkyPNG::INTERLACING_NONE; ChunkyPNG::INTERLACING_NONE
          when true, ChunkyPNG::INTERLACING_ADAM7;      ChunkyPNG::INTERLACING_ADAM7
          else encoding[:interlace]
        end

        encoding[:filtering] ||= case encoding[:compression]
          when Zlib::BEST_COMPRESSION; ChunkyPNG::FILTER_PAETH
          when Zlib::NO_COMPRESSION..Zlib::BEST_SPEED; ChunkyPNG::FILTER_NONE
          else ChunkyPNG::FILTER_UP
        end
        return encoding
      end
      
      # Encodes the canvas according to the PNG format specification with a given color 
      # mode, possibly with interlacing.
      # @param [Integer] color_mode The color mode to use for encoding.
      # @param [Integer] bit_depth The bit depth of the image.
      # @param [Integer] interlace The interlacing method to use.
      # @return [String] The PNG encoded canvas as string.
      def encode_png_pixelstream(color_mode = ChunkyPNG::COLOR_TRUECOLOR, bit_depth = 8, interlace = ChunkyPNG::INTERLACING_NONE, filtering = ChunkyPNG::FILTER_NONE)

        if color_mode == ChunkyPNG::COLOR_INDEXED 
          raise ChunkyPNG::ExpectationFailed, "This palette is not suitable for encoding!" if encoding_palette.nil? || !encoding_palette.can_encode?
          raise ChunkyPNG::ExpectationFailed, "This palette has too many colors!" if encoding_palette.size > (1 << bit_depth)
        end

        case interlace
          when ChunkyPNG::INTERLACING_NONE;  encode_png_image_without_interlacing(color_mode, bit_depth, filtering)
          when ChunkyPNG::INTERLACING_ADAM7; encode_png_image_with_interlacing(color_mode, bit_depth, filtering)
          else raise ChunkyPNG::NotSupported, "Unknown interlacing method: #{interlace}!"
        end
      end

      # Encodes the canvas according to the PNG format specification with a given color mode.
      # @param [Integer] color_mode The color mode to use for encoding.
      # @param [Integer] bit_depth The bit depth of the image.
      # @param [Integer] filtering The filtering method to use.
      # @return [String] The PNG encoded canvas as string.
      def encode_png_image_without_interlacing(color_mode, bit_depth = 8, filtering = ChunkyPNG::FILTER_NONE)
        stream = ChunkyPNG::Datastream.empty_bytearray
        encode_png_image_pass_to_stream(stream, color_mode, bit_depth, filtering)
        stream
      end

      # Encodes the canvas according to the PNG format specification with a given color 
      # mode and Adam7 interlacing.
      #
      # This method will split the original canvas in 7 smaller canvases and encode them
      # one by one, concatenating the resulting strings.
      #
      # @param [Integer] color_mode The color mode to use for encoding.
      # @param [Integer] bit_depth The bit depth of the image.
      # @param [Integer] filtering The filtering method to use.
      # @return [String] The PNG encoded canvas as string.
      def encode_png_image_with_interlacing(color_mode, bit_depth = 8, filtering = ChunkyPNG::FILTER_NONE)
        stream = ChunkyPNG::Datastream.empty_bytearray
        0.upto(6) do |pass|
          subcanvas = self.class.adam7_extract_pass(pass, self)
          subcanvas.encoding_palette = encoding_palette
          subcanvas.encode_png_image_pass_to_stream(stream, color_mode, bit_depth, filtering)
        end
        stream
      end

      # Encodes the canvas to a stream, in a given color mode.
      # @param [String] stream The stream to write to.
      # @param [Integer] color_mode The color mode to use for encoding.
      # @param [Integer] bit_depth The bit depth of the image.
      # @param [Integer] filtering The filtering method to use.
      def encode_png_image_pass_to_stream(stream, color_mode, bit_depth, filtering)

        start_pos  = stream.bytesize
        pixel_size = Color.pixel_bytesize(color_mode)
        line_width = Color.scanline_bytesize(color_mode, bit_depth, width)
        
        # Determine the filter method
        encode_method = encode_png_pixels_to_scanline_method(color_mode, bit_depth)
        filter_method = case filtering
          when ChunkyPNG::FILTER_SUB;     :encode_png_str_scanline_sub
          when ChunkyPNG::FILTER_UP;      :encode_png_str_scanline_up
          when ChunkyPNG::FILTER_AVERAGE; :encode_png_str_scanline_average
          when ChunkyPNG::FILTER_PAETH;   :encode_png_str_scanline_paeth
          else nil
        end
        
        0.upto(height - 1) do |y|
          stream << send(encode_method, row(y))
        end
        
        # Now, apply filtering if any
        if filter_method
          (height - 1).downto(0) do |y|
            pos = start_pos + y * (line_width + 1)
            prev_pos = (y == 0) ? nil : pos - (line_width + 1)
            send(filter_method, stream, pos, prev_pos, line_width, pixel_size)
          end
        end
      end
      
      # Encodes a line of pixels using 8-bit truecolor mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_truecolor_8bit(pixels)
        pixels.pack('x' + ('NX' * width))
      end
      
      # Encodes a line of pixels using 8-bit truecolor alpha mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_truecolor_alpha_8bit(pixels)
        pixels.pack("xN#{width}")
      end

      # Encodes a line of pixels using 1-bit indexed mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_indexed_1bit(pixels)
        chars = []
        pixels.each_slice(8) do |p1, p2, p3, p4, p5, p6, p7, p8|
          chars << ((encoding_palette.index(p1) << 7) |
                    (encoding_palette.index(p2) << 6) |
                    (encoding_palette.index(p3) << 5) |
                    (encoding_palette.index(p4) << 4) |
                    (encoding_palette.index(p5) << 3) |
                    (encoding_palette.index(p6) << 2) |
                    (encoding_palette.index(p7) << 1) |
                    (encoding_palette.index(p8)))
        end
        chars.pack('xC*')
      end
      
      # Encodes a line of pixels using 2-bit indexed mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_indexed_2bit(pixels)
        chars = []
        pixels.each_slice(4) do |p1, p2, p3, p4|
          chars << ((encoding_palette.index(p1) << 6) |
                    (encoding_palette.index(p2) << 4) |
                    (encoding_palette.index(p3) << 2) |
                    (encoding_palette.index(p4)))
        end
        chars.pack('xC*')
      end
      
      # Encodes a line of pixels using 4-bit indexed mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_indexed_4bit(pixels)
        chars = []
        pixels.each_slice(2) do |p1, p2|
          chars << ((encoding_palette.index(p1) << 4) | (encoding_palette.index(p2)))
        end
        chars.pack('xC*')
      end
      
      # Encodes a line of pixels using 8-bit indexed mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_indexed_8bit(pixels)
        pixels.map { |p| encoding_palette.index(p) }.pack("xC#{width}")
      end
      
      # Encodes a line of pixels using 1-bit grayscale mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_grayscale_1bit(pixels)
        chars = []
        pixels.each_slice(8) do |p1, p2, p3, p4, p5, p6, p7, p8|
          chars << ((p1.nil? ? 0 : (p1 & 0x0000ffff) >> 15 << 7) |
                    (p2.nil? ? 0 : (p2 & 0x0000ffff) >> 15 << 6) |
                    (p3.nil? ? 0 : (p3 & 0x0000ffff) >> 15 << 5) |
                    (p4.nil? ? 0 : (p4 & 0x0000ffff) >> 15 << 4) |
                    (p5.nil? ? 0 : (p5 & 0x0000ffff) >> 15 << 3) |
                    (p6.nil? ? 0 : (p6 & 0x0000ffff) >> 15 << 2) |
                    (p7.nil? ? 0 : (p7 & 0x0000ffff) >> 15 << 1) |
                    (p8.nil? ? 0 : (p8 & 0x0000ffff) >> 15))
        end
        chars.pack('xC*')
      end
      
      # Encodes a line of pixels using 2-bit grayscale mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_grayscale_2bit(pixels)
        chars = []
        pixels.each_slice(4) do |p1, p2, p3, p4|
          chars << ((p1.nil? ? 0 : (p1 & 0x0000ffff) >> 14 << 6) |
                    (p2.nil? ? 0 : (p2 & 0x0000ffff) >> 14 << 4) |
                    (p3.nil? ? 0 : (p3 & 0x0000ffff) >> 14 << 2) |
                    (p4.nil? ? 0 : (p4 & 0x0000ffff) >> 14))
        end
        chars.pack('xC*')
      end
      
      # Encodes a line of pixels using 2-bit grayscale mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_grayscale_4bit(pixels)
        chars = []
        pixels.each_slice(2) do |p1, p2|
          chars << ((p1.nil? ? 0 : ((p1 & 0x0000ffff) >> 12) << 4) | (p2.nil? ? 0 : ((p2 & 0x0000ffff) >> 12)))
        end
        chars.pack('xC*')
      end
      
      # Encodes a line of pixels using 8-bit grayscale mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_grayscale_8bit(pixels)
        pixels.map { |p| p >> 8 }.pack("xC#{width}")
      end

      # Encodes a line of pixels using 8-bit grayscale alpha mode.
      # @param [Array<Integer>] pixels A row of pixels of the original image.
      # @return [String] The encoded scanline as binary string
      def encode_png_pixels_to_scanline_grayscale_alpha_8bit(pixels)
        pixels.pack("xn#{width}")
      end
      
      
      # Returns the method name to use to decode scanlines into pixels.
      # @param [Integer] color_mode The color mode of the image.
      # @param [Integer] depth The bit depth of the image.
      # @return [Symbol] The method name to use for decoding, to be called on the canvas class.
      # @raise [ChunkyPNG::NotSupported] when the color_mode and/or bit depth is not supported.
      def encode_png_pixels_to_scanline_method(color_mode, depth)
        encoder_method = case color_mode
          when ChunkyPNG::COLOR_TRUECOLOR;       :"encode_png_pixels_to_scanline_truecolor_#{depth}bit"
          when ChunkyPNG::COLOR_TRUECOLOR_ALPHA; :"encode_png_pixels_to_scanline_truecolor_alpha_#{depth}bit"
          when ChunkyPNG::COLOR_INDEXED;         :"encode_png_pixels_to_scanline_indexed_#{depth}bit"
          when ChunkyPNG::COLOR_GRAYSCALE;       :"encode_png_pixels_to_scanline_grayscale_#{depth}bit"
          when ChunkyPNG::COLOR_GRAYSCALE_ALPHA; :"encode_png_pixels_to_scanline_grayscale_alpha_#{depth}bit"
          else nil
        end
        
        raise ChunkyPNG::NotSupported, "No encoder found for color mode #{color_mode} and #{depth}-bit depth!" unless respond_to?(encoder_method, true)
        encoder_method
      end
      


      # Encodes a scanline of a pixelstream without filtering. This is a no-op.
      # @param [String] stream The pixelstream to work on. This string will be modified.
      # @param [Integer] pos The starting position of the scanline.
      # @param [Integer, nil] prev_pos The starting position of the previous scanline. <tt>nil</tt> if
      #     this is the first line.
      # @param [Integer] line_width The number of bytes in this scanline, without counting the filtering
      #     method byte.
      # @param [Integer] pixel_size The number of bytes used per pixel.
      # @return [void]
      def encode_png_str_scanline_none(stream, pos, prev_pos, line_width, pixel_size)
        # noop - this method shouldn't get called at all.
      end

      # Encodes a scanline of a pixelstream using SUB filtering. This will modify the stream.
      # @param (see #encode_png_str_scanline_none)
      # @return [void]
      def encode_png_str_scanline_sub(stream, pos, prev_pos, line_width, pixel_size)
        line_width.downto(1) do |i|
          a = (i > pixel_size) ? stream.getbyte(pos + i - pixel_size) : 0
          stream.setbyte(pos + i, (stream.getbyte(pos + i) - a) & 0xff)
        end
        stream.setbyte(pos, ChunkyPNG::FILTER_SUB)
      end

      # Encodes a scanline of a pixelstream using UP filtering. This will modify the stream.
      # @param (see #encode_png_str_scanline_none)
      # @return [void]
      def encode_png_str_scanline_up(stream, pos, prev_pos, line_width, pixel_size)
        line_width.downto(1) do |i|
          b = prev_pos ? stream.getbyte(prev_pos + i) : 0
          stream.setbyte(pos + i, (stream.getbyte(pos + i) - b) & 0xff)
        end
        stream.setbyte(pos, ChunkyPNG::FILTER_UP)
      end
      
      # Encodes a scanline of a pixelstream using AVERAGE filtering. This will modify the stream.
      # @param (see #encode_png_str_scanline_none)
      # @return [void]
      def encode_png_str_scanline_average(stream, pos, prev_pos, line_width, pixel_size)
        line_width.downto(1) do |i|
          a = (i > pixel_size) ? stream.getbyte(pos + i - pixel_size) : 0
          b = prev_pos ? stream.getbyte(prev_pos + i) : 0
          stream.setbyte(pos + i, (stream.getbyte(pos + i) - ((a + b) >> 1)) & 0xff)
        end
        stream.setbyte(pos, ChunkyPNG::FILTER_AVERAGE)
      end
      
      # Encodes a scanline of a pixelstream using PAETH filtering. This will modify the stream.
      # @param (see #encode_png_str_scanline_none)
      # @return [void]
      def encode_png_str_scanline_paeth(stream, pos, prev_pos, line_width, pixel_size)
        line_width.downto(1) do |i|
          a = (i > pixel_size) ? stream.getbyte(pos + i - pixel_size) : 0
          b = (prev_pos) ? stream.getbyte(prev_pos + i) : 0
          c = (prev_pos && i > pixel_size) ? stream.getbyte(prev_pos + i - pixel_size) : 0
          p = a + b - c
          pa = (p - a).abs
          pb = (p - b).abs
          pc = (p - c).abs
          pr = (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c)
          stream.setbyte(pos + i, (stream.getbyte(pos + i) - pr) & 0xff)
        end
        stream.setbyte(pos, ChunkyPNG::FILTER_PAETH)
      end      
    end
  end
end
