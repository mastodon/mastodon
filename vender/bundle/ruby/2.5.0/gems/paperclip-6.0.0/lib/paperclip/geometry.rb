module Paperclip

  # Defines the geometry of an image.
  class Geometry
    attr_accessor :height, :width, :modifier

    EXIF_ROTATED_ORIENTATION_VALUES = [5, 6, 7, 8]

    # Gives a Geometry representing the given height and width
    def initialize(width = nil, height = nil, modifier = nil)
      if width.is_a?(Hash)
        options = width
        @height = options[:height].to_f
        @width = options[:width].to_f
        @modifier = options[:modifier]
        @orientation = options[:orientation].to_i
      else
        @height = height.to_f
        @width  = width.to_f
        @modifier = modifier
      end
    end

    # Extracts the Geometry from a file (or path to a file)
    def self.from_file(file)
      GeometryDetector.new(file).make
    end

    # Extracts the Geometry from a "WxH,O" string
    # Where W is the width, H is the height,
    # and O is the EXIF orientation
    def self.parse(string)
      GeometryParser.new(string).make
    end

    # Swaps the height and width if necessary
    def auto_orient
      if EXIF_ROTATED_ORIENTATION_VALUES.include?(@orientation)
        @height, @width = @width, @height
        @orientation -= 4
      end
    end

    # True if the dimensions represent a square
    def square?
      height == width
    end

    # True if the dimensions represent a horizontal rectangle
    def horizontal?
      height < width
    end

    # True if the dimensions represent a vertical rectangle
    def vertical?
      height > width
    end

    # The aspect ratio of the dimensions.
    def aspect
      width / height
    end

    # Returns the larger of the two dimensions
    def larger
      [height, width].max
    end

    # Returns the smaller of the two dimensions
    def smaller
      [height, width].min
    end

    # Returns the width and height in a format suitable to be passed to Geometry.parse
    def to_s
      s = ""
      s << width.to_i.to_s if width > 0
      s << "x#{height.to_i}" if height > 0
      s << modifier.to_s
      s
    end

    # Same as to_s
    def inspect
      to_s
    end

    # Returns the scaling and cropping geometries (in string-based ImageMagick format)
    # neccessary to transform this Geometry into the Geometry given. If crop is true,
    # then it is assumed the destination Geometry will be the exact final resolution.
    # In this case, the source Geometry is scaled so that an image containing the
    # destination Geometry would be completely filled by the source image, and any
    # overhanging image would be cropped. Useful for square thumbnail images. The cropping
    # is weighted at the center of the Geometry.
    def transformation_to dst, crop = false
      if crop
        ratio = Geometry.new( dst.width / self.width, dst.height / self.height )
        scale_geometry, scale = scaling(dst, ratio)
        crop_geometry         = cropping(dst, ratio, scale)
      else
        scale_geometry        = dst.to_s
      end

      [ scale_geometry, crop_geometry ]
    end

    # resize to a new geometry
    # @param geometry [String] the Paperclip geometry definition to resize to
    # @example
    #   Paperclip::Geometry.new(150, 150).resize_to('50x50!')
    #   #=> Paperclip::Geometry(50, 50)
    def resize_to(geometry)
      new_geometry = Paperclip::Geometry.parse geometry
      case new_geometry.modifier
      when '!', '#'
        new_geometry
      when '>'
        if new_geometry.width >= self.width && new_geometry.height >= self.height
          self
        else
          scale_to new_geometry
        end
      when '<'
        if new_geometry.width <= self.width || new_geometry.height <= self.height
          self
        else
          scale_to new_geometry
        end
      else
        scale_to new_geometry
      end
    end

    private

    def scaling dst, ratio
      if ratio.horizontal? || ratio.square?
        [ "%dx" % dst.width, ratio.width ]
      else
        [ "x%d" % dst.height, ratio.height ]
      end
    end

    def cropping dst, ratio, scale
      if ratio.horizontal? || ratio.square?
        "%dx%d+%d+%d" % [ dst.width, dst.height, 0, (self.height * scale - dst.height) / 2 ]
      else
        "%dx%d+%d+%d" % [ dst.width, dst.height, (self.width * scale - dst.width) / 2, 0 ]
      end
    end

    # scale to the requested geometry and preserve the aspect ratio
    def scale_to(new_geometry)
      scale = [new_geometry.width.to_f / self.width.to_f , new_geometry.height.to_f / self.height.to_f].min
      Paperclip::Geometry.new((self.width * scale).round, (self.height * scale).round)
    end
  end
end
