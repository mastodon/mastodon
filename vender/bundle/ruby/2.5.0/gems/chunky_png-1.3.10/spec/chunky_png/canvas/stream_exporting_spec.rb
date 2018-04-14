require 'spec_helper'

describe ChunkyPNG::Canvas do

  describe '#to_rgba_stream' do
    it "should export a sample canvas to an RGBA stream correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [ChunkyPNG::Color.rgba(1,2,3,4), ChunkyPNG::Color.rgba(5,6,7,8),
                                            ChunkyPNG::Color.rgba(4,3,2,1), ChunkyPNG::Color.rgba(8,7,6,5)])

      expect(canvas.to_rgba_stream).to eql  [1,2,3,4,5,6,7,8,4,3,2,1,8,7,6,5].pack('C16')
    end

    it "should export an image to an RGBA datastream correctly" do
      expect(reference_canvas('pixelstream_reference').to_rgba_stream).to eql resource_data('pixelstream.rgba')
    end
  end

  describe '#to_rgb_stream' do
    it "should export a sample canvas to an RGBA stream correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [ChunkyPNG::Color.rgba(1,2,3,4), ChunkyPNG::Color.rgba(5,6,7,8),
                                            ChunkyPNG::Color.rgba(4,3,2,1), ChunkyPNG::Color.rgba(8,7,6,5)])

      expect(canvas.to_rgb_stream).to eql [1,2,3,5,6,7,4,3,2,8,7,6].pack('C12')
    end

    it "should export an image to an RGB datastream correctly" do
      expect(reference_canvas('pixelstream_reference').to_rgb_stream).to eql resource_data('pixelstream.rgb')
    end
  end

  describe '#to_grayscale_stream' do

    it "should export a grayscale image to a grayscale datastream correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [ChunkyPNG::Color.grayscale(1), ChunkyPNG::Color.grayscale(2),
                                            ChunkyPNG::Color.grayscale(3), ChunkyPNG::Color.grayscale(4)])
      expect(canvas.to_grayscale_stream).to eql [1,2,3,4].pack('C4')
    end


    it "should export a color image to a grayscale datastream, using B values" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [ChunkyPNG::Color.rgba(1,2,3,4), ChunkyPNG::Color.rgba(5,6,7,8),
                                            ChunkyPNG::Color.rgba(4,3,2,1), ChunkyPNG::Color.rgba(8,7,6,5)])
      expect(canvas.to_grayscale_stream).to eql [3,7,2,6].pack('C4')
    end
  end

  describe '#to_alpha_channel_stream' do
    it "should export an opaque image to an alpha channel datastream correctly" do
      grayscale_array = Array.new(reference_canvas('pixelstream_reference').pixels.length, 255)
      expect(reference_canvas('pixelstream_reference').to_alpha_channel_stream).to eql grayscale_array.pack('C*')
    end

    it "should export a transparent image to an alpha channel datastream correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [ChunkyPNG::Color.rgba(1,2,3,4), ChunkyPNG::Color.rgba(5,6,7,8),
                                            ChunkyPNG::Color.rgba(4,3,2,1), ChunkyPNG::Color.rgba(8,7,6,5)])
      expect(canvas.to_alpha_channel_stream).to eql [4,8,1,5].pack('C4')
    end
  end
end
