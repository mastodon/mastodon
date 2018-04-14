require 'spec_helper'

describe ChunkyPNG::Canvas do

  describe '#to_data_url' do
    it "should export a sample canvas to an RGBA stream correctly" do
      canvas = ChunkyPNG::Canvas.new(2, 2, [ChunkyPNG::Color.rgba(1,2,3,4), ChunkyPNG::Color.rgba(5,6,7,8),
                                            ChunkyPNG::Color.rgba(4,3,2,1), ChunkyPNG::Color.rgba(8,7,6,5)])

      expect(canvas.to_data_url).to eql "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAgMAAAAP2OW3AAAADFBMVEUBAgMEAwIFBgcIBwazgAAdAAAABHRSTlMEAQgFhYDlfQAAAAxJREFUeJxjUmAKAAAAwAB1GNhIEwAAAABJRU5ErkJggg=="
    end
  end
end
