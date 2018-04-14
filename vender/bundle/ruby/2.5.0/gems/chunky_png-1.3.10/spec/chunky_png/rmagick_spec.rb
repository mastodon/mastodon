require 'spec_helper'

begin
  require 'chunky_png/rmagick'

  describe ChunkyPNG::RMagick do

    it "should import an image from RMagick correctly" do
      image = Magick::Image.read(resource_file('composited.png')).first
      canvas = ChunkyPNG::RMagick.import(image)
      expect(canvas).to eql reference_canvas('composited')
    end

    it "should export an image to RMagick correctly" do
      canvas = reference_canvas('composited')
      image  = ChunkyPNG::RMagick.export(canvas)
      image.format = 'PNG32'
      expect(canvas).to eql ChunkyPNG::Canvas.from_blob(image.to_blob)
    end
  end
rescue LoadError => e
  # skipping RMagick tests
end
