require 'rmagick'

module ChunkyPNG
  
  # Methods for importing and exporting RMagick image objects.
  #
  # By default, this module is disabled because of the dependency on RMagick.
  # You need to include this module yourself if you want to use it. 
  #
  # @example
  #
  #    require 'rmagick'
  #    require 'chunky_png/rmagick'
  #    
  #    canvas = ChunkyPNG::Canvas.from_file('filename.png')
  #    image = ChunkyPNG::RMagick.export(canvas)
  #    
  #    # do something with the image using RMagick
  #    
  #    updated_canvas = ChunkyPNG::RMagick.import(image)
  #
  module RMagick
    
    extend self
    
    # Imports an RMagick image as Canvas object.
    # @param [Magick::Image] image The image to import
    # @return [ChunkyPNG::Canvas] The canvas, constructed from the RMagick image.
    def import(image)
      pixels = image.export_pixels_to_str(0, 0, image.columns, image.rows, 'RGBA')
      ChunkyPNG::Canvas.from_rgba_stream(image.columns, image.rows, pixels)
    end

    # Exports a Canvas as RMagick image instance.
    # @param [ChunkyPNG::Canvas] canvas The canvas to export.
    # @return [Magick::Image] The RMagick image constructed from the Canvas instance.
    def export(canvas)
      image = Magick::Image.new(canvas.width, canvas.height)
      image.import_pixels(0,0, canvas.width, canvas.height, 'RGBA', canvas.pixels.pack('N*'))
      image
    end
  end
end
