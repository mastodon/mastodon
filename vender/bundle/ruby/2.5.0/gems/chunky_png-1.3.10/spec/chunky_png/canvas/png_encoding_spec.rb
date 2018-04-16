require 'spec_helper'

describe ChunkyPNG::Canvas::PNGEncoding do
  include ChunkyPNG::Canvas::PNGEncoding

  context 'determining encoding options' do
    [:indexed, :grayscale, :grayscale_alpha, :truecolor, :truecolor_alpha].each do |color_mode_name|
      it "should encode an image with color mode #{color_mode_name} correctly" do
        canvas = ChunkyPNG::Canvas.new(10, 10, ChunkyPNG::Color.rgb(100, 100, 100))
        color_mode = ChunkyPNG.const_get("COLOR_#{color_mode_name.to_s.upcase}")
        blob = canvas.to_blob(:color_mode => color_mode)

        ds = ChunkyPNG::Datastream.from_blob(blob)
        expect(ds.header_chunk.color).to eql color_mode
        expect(ChunkyPNG::Canvas.from_datastream(ds)).to eql ChunkyPNG::Canvas.new(10, 10, ChunkyPNG::Color.rgb(100, 100, 100))
      end
    end

    it "should encode an image with 2 colors using 1-bit indexed color mode" do
      @canvas = ChunkyPNG::Canvas.from_file(png_suite_file('basic', 'basn3p01.png'))
      ds = ChunkyPNG::Datastream.from_blob(@canvas.to_blob)
      expect(ds.header_chunk.color).to eql ChunkyPNG::COLOR_INDEXED
      expect(ds.header_chunk.depth).to eql 1
      expect(@canvas).to eql ChunkyPNG::Canvas.from_datastream(ds)
    end

    it "should encode an image with 4 colors using 2-bit indexed color mode" do
      @canvas = ChunkyPNG::Canvas.from_file(png_suite_file('basic', 'basn3p02.png'))
      ds = ChunkyPNG::Datastream.from_blob(@canvas.to_blob)
      expect(ds.header_chunk.color).to eql ChunkyPNG::COLOR_INDEXED
      expect(ds.header_chunk.depth).to eql 2
      expect(@canvas).to eql ChunkyPNG::Canvas.from_datastream(ds)
    end

    it "should encode an image with 16 colors using 4-bit indexed color mode" do
      @canvas = ChunkyPNG::Canvas.from_file(png_suite_file('basic', 'basn3p04.png'))
      ds = ChunkyPNG::Datastream.from_blob(@canvas.to_blob)
      expect(ds.header_chunk.color).to eql ChunkyPNG::COLOR_INDEXED
      expect(ds.header_chunk.depth).to eql 4
      expect(@canvas).to eql ChunkyPNG::Canvas.from_datastream(ds)
    end

    it "should encode an image with 256 colors using 8-bit indexed color mode" do
      @canvas = ChunkyPNG::Canvas.from_file(png_suite_file('basic', 'basn3p08.png'))
      ds = ChunkyPNG::Datastream.from_blob(@canvas.to_blob)
      expect(ds.header_chunk.color).to eql ChunkyPNG::COLOR_INDEXED
      expect(ds.header_chunk.depth).to eql 8
      expect(@canvas).to eql ChunkyPNG::Canvas.from_datastream(ds)
    end

    it "should use a higher bit depth than necessary if requested" do
      @canvas = ChunkyPNG::Canvas.from_file(png_suite_file('basic', 'basn3p01.png'))
      ds = ChunkyPNG::Datastream.from_blob(@canvas.to_blob(:bit_depth => 4))
      expect(ds.header_chunk.color).to eql ChunkyPNG::COLOR_INDEXED
      expect(ds.header_chunk.depth).to eql 4
      expect(@canvas).to eql ChunkyPNG::Canvas.from_datastream(ds)
    end

    it "should encode an image with interlacing correctly" do
      input_canvas = ChunkyPNG::Canvas.from_file(resource_file('operations.png'))
      blob = input_canvas.to_blob(:interlace => true)

      ds = ChunkyPNG::Datastream.from_blob(blob)
      expect(ds.header_chunk.interlace).to eql ChunkyPNG::INTERLACING_ADAM7
      expect(ChunkyPNG::Canvas.from_datastream(ds)).to eql input_canvas
    end

    it "should save an image using the normal routine correctly" do
      canvas = reference_canvas('operations')
      expect(Zlib::Deflate).to receive(:deflate).with(anything, Zlib::DEFAULT_COMPRESSION).and_return('')
      canvas.to_blob
    end

    it "should save an image using the :fast_rgba routine correctly" do
      canvas = reference_canvas('operations')
      expect(canvas).to_not receive(:encode_png_str_scanline_none)
      expect(canvas).to_not receive(:encode_png_str_scanline_sub)
      expect(canvas).to_not receive(:encode_png_str_scanline_up)
      expect(canvas).to_not receive(:encode_png_str_scanline_average)
      expect(canvas).to_not receive(:encode_png_str_scanline_paeth)
      expect(Zlib::Deflate).to receive(:deflate).with(anything, Zlib::BEST_SPEED).and_return('')
      canvas.to_blob(:fast_rgba)
    end

    it "should save an image using the :good_compression routine correctly" do
      canvas = reference_canvas('operations')
      expect(canvas).to_not receive(:encode_png_str_scanline_none)
      expect(canvas).to_not receive(:encode_png_str_scanline_sub)
      expect(canvas).to_not receive(:encode_png_str_scanline_up)
      expect(canvas).to_not receive(:encode_png_str_scanline_average)
      expect(canvas).to_not receive(:encode_png_str_scanline_paeth)
      expect(Zlib::Deflate).to receive(:deflate).with(anything, Zlib::BEST_COMPRESSION).and_return('')
      canvas.to_blob(:good_compression)
    end

    it "should save an image using the :best_compression routine correctly" do
      canvas = reference_canvas('operations')
      expect(canvas).to receive(:encode_png_str_scanline_paeth).exactly(canvas.height).times
      expect(Zlib::Deflate).to receive(:deflate).with(anything, Zlib::BEST_COMPRESSION).and_return('')
      canvas.to_blob(:best_compression)
    end

    it "should save an image with black and white only if requested" do
      ds = ChunkyPNG::Datastream.from_blob(reference_canvas('lines').to_blob(:black_and_white))
      expect(ds.header_chunk.color).to eql ChunkyPNG::COLOR_GRAYSCALE
      expect(ds.header_chunk.depth).to eql 1
    end
  end

  describe 'different color modes and bit depths' do
    before do
      @canvas = ChunkyPNG::Canvas.new(2, 2)

      @canvas[0, 0] = ChunkyPNG::Color.rgba(  1,   2,   3,   4)
      @canvas[1, 0] = ChunkyPNG::Color.rgba(252, 253, 254, 255)
      @canvas[0, 1] = ChunkyPNG::Color.rgba(255, 254, 253, 252)
      @canvas[1, 1] = ChunkyPNG::Color.rgba(  4,   3,   2,   1)

      @canvas.encoding_palette = @canvas.palette
      @canvas.encoding_palette.to_plte_chunk
    end

    it "should encode using 8-bit RGBA mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_TRUECOLOR_ALPHA, 8, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x01\x02\x03\x04\xFC\xFD\xFE\xFF\0\xFF\xFE\xFD\xFC\x04\x03\x02\x01")
    end

    it "should encode using 8 bit RGB mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_TRUECOLOR, 8, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x01\x02\x03\xFC\xFD\xFE\0\xFF\xFE\xFD\x04\x03\x02")
    end

    it "should encode using 1-bit grayscale mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_GRAYSCALE, 1, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x40\0\x80") # Using the B byte of the pixel == 3, assuming R == G == B for grayscale images
    end

    it "should encode using 2-bit grayscale mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_GRAYSCALE, 2, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x30\0\xC0") # Using the B byte of the pixel == 3, assuming R == G == B for grayscale images
    end

    it "should encode using 4-bit grayscale mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_GRAYSCALE, 4, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x0F\0\xF0") # Using the B byte of the pixel == 3, assuming R == G == B for grayscale images
    end

    it "should encode using 8-bit grayscale mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_GRAYSCALE, 8, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x03\xFE\0\xFD\x02") # Using the B byte of the pixel == 3, assuming R == G == B for grayscale images
    end

    it "should not encode using 1-bit indexed mode because the image has too many colors" do
      expect {
        @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_INDEXED, 1, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      }.to raise_error(ChunkyPNG::ExpectationFailed)
    end

    it "should encode using 2-bit indexed mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_INDEXED, 2, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x20\0\xD0")
    end

    it "should encode using 4-bit indexed mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_INDEXED, 4, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x02\0\x31")
    end

    it "should encode using 8-bit indexed mode correctly" do
      stream = @canvas.encode_png_pixelstream(ChunkyPNG::COLOR_INDEXED, 8, ChunkyPNG::INTERLACING_NONE, ChunkyPNG::FILTER_NONE)
      expect(stream).to eql ChunkyPNG.force_binary("\0\x00\x02\0\x03\x01")
    end
  end

  describe 'different filter methods' do

    it "should encode a scanline without filtering correctly" do
      stream = [ChunkyPNG::FILTER_NONE, 0, 0, 0, 1, 1, 1, 2, 2, 2].pack('C*')
      encode_png_str_scanline_none(stream, 0, nil, 9, 3)
      expect(stream.unpack('C*')).to eql [ChunkyPNG::FILTER_NONE, 0, 0, 0, 1, 1, 1, 2, 2, 2]
    end

    it "should encode a scanline with sub filtering correctly" do
      stream = [ChunkyPNG::FILTER_NONE, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                ChunkyPNG::FILTER_NONE, 255, 255, 255, 255, 255, 255, 255, 255, 255].pack('C*')

      # Check line with previous line
      encode_png_str_scanline_sub(stream, 10, 0, 9, 3)
      expect(stream.unpack('@10C10')).to eql [ChunkyPNG::FILTER_SUB, 255, 255, 255, 0, 0, 0, 0, 0, 0]

      # Check line without previous line
      encode_png_str_scanline_sub(stream, 0, nil, 9, 3)
      expect(stream.unpack('@0C10')).to eql [ChunkyPNG::FILTER_SUB, 255, 255, 255, 0, 0, 0, 0, 0, 0]
    end

    it "should encode a scanline with up filtering correctly" do
      stream = [ChunkyPNG::FILTER_NONE, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                ChunkyPNG::FILTER_NONE, 255, 255, 255, 255, 255, 255, 255, 255, 255].pack('C*')

      # Check line with previous line
      encode_png_str_scanline_up(stream, 10, 0, 9, 3)
      expect(stream.unpack('@10C10')).to eql [ChunkyPNG::FILTER_UP, 0, 0, 0, 0, 0, 0, 0, 0, 0]

      # Check line without previous line
      encode_png_str_scanline_up(stream, 0, nil, 9, 3)
      expect(stream.unpack('@0C10')).to eql [ChunkyPNG::FILTER_UP, 255, 255, 255, 255, 255, 255, 255, 255, 255]
    end

    it "should encode a scanline with average filtering correctly" do
      stream = [ChunkyPNG::FILTER_NONE, 10, 20, 30, 40, 50, 60, 70, 80,   80, 100, 110, 120,
                ChunkyPNG::FILTER_NONE,  5, 10, 25, 45, 45, 55, 80, 125, 105, 150, 114, 165].pack('C*')

      # Check line with previous line
      encode_png_str_scanline_average(stream, 13, 0, 12, 3)
      expect(stream.unpack('@13C13')).to eql [ChunkyPNG::FILTER_AVERAGE, 0, 0, 10, 23, 15, 13, 23, 63, 38, 60, 253, 53]

      # Check line without previous line
      encode_png_str_scanline_average(stream, 0, nil, 12, 3)
      expect(stream.unpack('@0C13')).to eql [ChunkyPNG::FILTER_AVERAGE, 10, 20, 30, 35, 40, 45, 50, 55, 50, 65, 70, 80]
    end

    it "should encode a scanline with paeth filtering correctly" do
      stream = [ChunkyPNG::FILTER_NONE, 10, 20, 30, 40, 50, 60, 70,  80, 80, 100, 110, 120,
                ChunkyPNG::FILTER_NONE, 10, 20, 40, 60, 60, 60, 70, 120, 90, 120,  54, 120].pack('C*')

      # Check line with previous line
      encode_png_str_scanline_paeth(stream, 13, 0, 12, 3)
      expect(stream.unpack('@13C13')).to eql [ChunkyPNG::FILTER_PAETH, 0, 0, 10, 20, 10, 0, 0, 40, 10, 20, 190, 0]

      # Check line without previous line
      encode_png_str_scanline_paeth(stream, 0, nil, 12, 3)
      expect(stream.unpack('@0C13')).to eql [ChunkyPNG::FILTER_PAETH, 10, 20, 30, 30, 30, 30, 30, 30, 20, 30, 30, 40]
    end
  end
end
