require 'spec_helper'

describe ChunkyPNG::Canvas::PNGDecoding do
  include ChunkyPNG::Canvas::PNGDecoding

  describe '#decode_png_scanline' do

    it "should decode a line without filtering as is" do
      stream = [ChunkyPNG::FILTER_NONE, 255, 255, 255, 255, 255, 255, 255, 255, 255].pack('C*')
      decode_png_str_scanline(stream, 0, nil, 9, 3)
      expect(stream.unpack('@1C*')).to eql [255, 255, 255, 255, 255, 255, 255, 255, 255]
    end

    it "should decode a line with sub filtering correctly" do
      # all white pixels
      stream = [ChunkyPNG::FILTER_SUB, 255, 255, 255, 0, 0, 0, 0, 0, 0].pack('C*')
      decode_png_str_scanline(stream, 0, nil, 9, 3)
      expect(stream.unpack('@1C*')).to eql [255, 255, 255, 255, 255, 255, 255, 255, 255]

      # all black pixels
      stream = [ChunkyPNG::FILTER_SUB, 0, 0, 0, 0, 0, 0, 0, 0, 0].pack('C*')
      decode_png_str_scanline(stream, 0, nil, 9, 3)
      expect(stream.unpack('@1C*')).to eql [0, 0, 0, 0, 0, 0, 0, 0, 0]

      # various colors
      stream = [ChunkyPNG::FILTER_SUB, 255, 0, 45, 0, 255, 0, 112, 200, 178].pack('C*')
      decode_png_str_scanline(stream, 0, nil, 9, 3)
      expect(stream.unpack('@1C*')).to eql [255, 0, 45, 255, 255, 45, 111, 199, 223]
    end

    it "should decode a line with up filtering correctly" do
      # previous line has various pixels
      previous = [ChunkyPNG::FILTER_UP, 255, 255, 255, 127, 127, 127, 0, 0, 0]
      current  = [ChunkyPNG::FILTER_UP, 0, 127, 255, 0, 127, 255, 0, 127, 255]
      stream   = (previous + current).pack('C*')
      decode_png_str_scanline(stream, 10, 0, 9, 3)
      expect(stream.unpack('@11C9')).to eql [255, 126, 254, 127, 254, 126, 0, 127, 255]
    end

    it "should decode a line with average filtering correctly" do
      previous = [ChunkyPNG::FILTER_AVERAGE, 10, 20, 30, 40, 50, 60, 70, 80, 80, 100, 110, 120]
      current  = [ChunkyPNG::FILTER_AVERAGE,  0,  0, 10, 23, 15, 13, 23, 63, 38,  60, 253,  53]
      stream   = (previous + current).pack('C*')
      decode_png_str_scanline(stream, 13, 0, 12, 3)
      expect(stream.unpack('@14C12')).to eql [5, 10, 25, 45, 45, 55, 80, 125, 105, 150, 114, 165]
    end

    it "should decode a line with paeth filtering correctly" do
      previous = [ChunkyPNG::FILTER_PAETH, 10, 20, 30, 40, 50, 60, 70, 80, 80, 100, 110, 120]
      current  = [ChunkyPNG::FILTER_PAETH,  0,  0, 10, 20, 10,  0,  0, 40, 10,  20, 190,   0]
      stream   = (previous + current).pack('C*')
      decode_png_str_scanline(stream, 13, 0, 12, 3)
      expect(stream.unpack('@14C12')).to eql [10, 20, 40, 60, 60, 60, 70, 120, 90, 120, 54, 120]
    end
  end

  describe '#decode_png_extract_4bit_value' do
    it "should extract the high bits successfully" do
      expect(decode_png_extract_4bit_value('10010110'.to_i(2), 0)).to eql '1001'.to_i(2)
    end

    it "should extract the low bits successfully" do
      expect(decode_png_extract_4bit_value('10010110'.to_i(2), 17)).to eql '0110'.to_i(2)
    end
  end

  describe '#decode_png_extract_2bit_value' do
    it "should extract the first 2 bits successfully" do
      expect(decode_png_extract_2bit_value('10010110'.to_i(2), 0)).to eql '10'.to_i(2)
    end

    it "should extract the second 2 bits successfully" do
      expect(decode_png_extract_2bit_value('10010110'.to_i(2), 5)).to eql '01'.to_i(2)
    end

    it "should extract the third 2 bits successfully" do
      expect(decode_png_extract_2bit_value('10010110'.to_i(2), 2)).to eql '01'.to_i(2)
    end

    it "should extract the low two bits successfully" do
      expect(decode_png_extract_2bit_value('10010110'.to_i(2), 7)).to eql '10'.to_i(2)
    end
  end

  describe '#decode_png_extract_1bit_value' do
    it "should extract all separate bits correctly" do
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 0)).to eql 1
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 1)).to eql 0
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 2)).to eql 0
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 3)).to eql 1
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 4)).to eql 0
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 5)).to eql 1
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 6)).to eql 1
      expect(decode_png_extract_1bit_value('10010110'.to_i(2), 7)).to eql 0
    end
  end
end
