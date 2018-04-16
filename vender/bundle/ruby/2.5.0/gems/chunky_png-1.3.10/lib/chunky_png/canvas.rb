require 'chunky_png/canvas/png_encoding'
require 'chunky_png/canvas/png_decoding'
require 'chunky_png/canvas/adam7_interlacing'
require 'chunky_png/canvas/stream_exporting'
require 'chunky_png/canvas/stream_importing'
require 'chunky_png/canvas/data_url_exporting'
require 'chunky_png/canvas/data_url_importing'
require 'chunky_png/canvas/operations'
require 'chunky_png/canvas/drawing'
require 'chunky_png/canvas/resampling'
require 'chunky_png/canvas/masking'

module ChunkyPNG
  # The ChunkyPNG::Canvas class represents a raster image as a matrix of
  # pixels.
  #
  # This class supports loading a Canvas from a PNG datastream, and creating a
  # {ChunkyPNG::Datastream PNG datastream} based on this matrix. ChunkyPNG
  # only supports 8-bit color depth, otherwise all of the PNG format's
  # variations are supported for both reading and writing.
  #
  # This class offers per-pixel access to the matrix by using x,y coordinates.
  # It uses a palette (see {ChunkyPNG::Palette}) to keep track of the
  # different colors used in this matrix.
  #
  # The pixels in the canvas are stored as 4-byte fixnum, representing 32-bit
  # RGBA colors (8 bit per channel). The module {ChunkyPNG::Color} is provided
  # to work more easily with these number as color values.
  #
  # The module {ChunkyPNG::Canvas::Operations} is imported for operations on
  # the whole canvas, like cropping and alpha compositing. Simple drawing
  # functions are imported from the {ChunkyPNG::Canvas::Drawing} module.
  class Canvas
    include PNGEncoding
    extend  PNGDecoding
    extend  Adam7Interlacing

    include StreamExporting
    extend  StreamImporting

    include DataUrlExporting
    extend  DataUrlImporting

    include Operations
    include Drawing
    include Resampling
    include Masking

    # @return [Integer] The number of columns in this canvas
    attr_reader :width

    # @return [Integer] The number of rows in this canvas
    attr_reader :height

    # @return [Array<ChunkyPNG::Color>] The list of pixels in this canvas.
    #   This array always should have +width * height+ elements.
    attr_reader :pixels


    #################################################################
    # CONSTRUCTORS
    #################################################################

    # Initializes a new Canvas instance.
    #
    # @overload initialize(width, height, background_color)
    #   @param [Integer] width The width in pixels of this canvas
    #   @param [Integer] height The height in pixels of this canvas
    #   @param [Integer, ...] background_color The initial background color of
    #     this canvas. This can be a color value or any value that
    #     {ChunkyPNG::Color.parse} can handle.
    #
    # @overload initialize(width, height, initial)
    #   @param [Integer] width The width in pixels of this canvas
    #   @param [Integer] height The height in pixels of this canvas
    #   @param [Array<Integer>] initial The initial pizel values. Must be an
    #     array with <tt>width * height</tt> elements.
    def initialize(width, height, initial = ChunkyPNG::Color::TRANSPARENT)
      @width, @height = width, height

      if initial.kind_of?(Array)
        unless initial.length == width * height
          raise ArgumentError, "The initial array should have #{width}x#{height} = #{width*height} elements!"
        end
        @pixels = initial
      else
        @pixels = Array.new(width * height, ChunkyPNG::Color.parse(initial))
      end
    end

    # Initializes a new Canvas instances when being cloned.
    # @param [ChunkyPNG::Canvas] other The canvas to duplicate
    # @return [void]
    # @private
    def initialize_copy(other)
      @width, @height = other.width, other.height
      @pixels = other.pixels.dup
    end

    # Creates a new canvas instance by duplicating another instance.
    # @param [ChunkyPNG::Canvas] canvas The canvas to duplicate
    # @return [ChunkyPNG::Canvas] The newly constructed canvas instance.
    def self.from_canvas(canvas)
      new(canvas.width, canvas.height, canvas.pixels.dup)
    end


    #################################################################
    # PROPERTIES
    #################################################################

    # Returns the dimension (width x height) for this canvas.
    # @return [ChunkyPNG::Dimension] A dimension instance with the width and
    #   height set for this canvas.
    def dimension
      ChunkyPNG::Dimension.new(width, height)
    end

    # Returns the area of this canvas in number of pixels.
    # @return [Integer] The number of pixels in this canvas
    def area
      pixels.length
    end

    # Replaces a single pixel in this canvas.
    # @param [Integer] x The x-coordinate of the pixel (column)
    # @param [Integer] y The y-coordinate of the pixel (row)
    # @param [Integer] color The new color for the provided coordinates.
    # @return [Integer] The new color value for this pixel, i.e.
    #   <tt>color</tt>.
    # @raise [ChunkyPNG::OutOfBounds] when the coordinates are outside of the
    #   image's dimensions.
    # @see #set_pixel
    def []=(x, y, color)
      assert_xy!(x, y)
      @pixels[y * width + x] = ChunkyPNG::Color.parse(color)
    end

    # Replaces a single pixel in this canvas, without bounds checking.
    #
    # This method return value and effects are undefined for coordinates
    # out of bounds of the canvas.
    #
    # @param [Integer] x The x-coordinate of the pixel (column)
    # @param [Integer] y The y-coordinate of the pixel (row)
    # @param [Integer] pixel The new color for the provided coordinates.
    # @return [Integer] The new color value for this pixel, i.e.
    #   <tt>color</tt>.
    def set_pixel(x, y, color)
      @pixels[y * width + x] = color
    end

    # Replaces a single pixel in this canvas, with bounds checking. It will do
    # noting if the provided coordinates are out of bounds.
    #
    # @param [Integer] x The x-coordinate of the pixel (column)
    # @param [Integer] y The y-coordinate of the pixel (row)
    # @param [Integer] pixel The new color value for the provided coordinates.
    # @return [Integer] The new color value for this pixel, i.e.
    #   <tt>color</tt>, or <tt>nil</tt> if the coordinates are out of bounds.
    def set_pixel_if_within_bounds(x, y, color)
      return unless include_xy?(x, y)
      @pixels[y * width + x] = color
    end

    # Returns a single pixel's color value from this canvas.
    # @param [Integer] x The x-coordinate of the pixel (column)
    # @param [Integer] y The y-coordinate of the pixel (row)
    # @return [Integer] The current color value at the provided coordinates.
    # @raise [ChunkyPNG::OutOfBounds] when the coordinates are outside of the
    #   image's dimensions.
    # @see #get_pixel
    def [](x, y)
      assert_xy!(x, y)
      @pixels[y * width + x]
    end

    # Returns a single pixel from this canvas, without checking bounds. The
    # return value for this method is undefined if the coordinates are out of
    # bounds.
    #
    # @param (see #[])
    # @return [Integer] The current pixel at the provided coordinates.
    def get_pixel(x, y)
      @pixels[y * width + x]
    end

    # Returns an extracted row as vector of pixels
    # @param [Integer] y The 0-based row index
    # @return [Array<Integer>] The vector of pixels in the requested row
    def row(y)
      assert_y!(y)
      pixels.slice(y * width, width)
    end

    # Returns an extracted column as vector of pixels.
    # @param [Integer] x The 0-based column index.
    # @return [Array<Integer>] The vector of pixels in the requested column.
    def column(x)
      assert_x!(x)
      (0...height).inject([]) { |pixels, y| pixels << get_pixel(x, y) }
    end

    # Replaces a row of pixels on this canvas.
    # @param [Integer] y The 0-based row index.
    # @param [Array<Integer>] vector The vector of pixels to replace the row
    #   with.
    # @return [void]
    def replace_row!(y, vector)
      assert_y!(y) && assert_width!(vector.length)
      pixels[y * width, width] = vector
    end

    # Replaces a column of pixels on this canvas.
    # @param [Integer] x The 0-based column index.
    # @param [Array<Integer>] vector The vector of pixels to replace the column
    #   with.
    # @return [void]
    def replace_column!(x, vector)
      assert_x!(x) && assert_height!(vector.length)
      for y in 0...height do
        set_pixel(x, y, vector[y])
      end
    end

    # Checks whether the given coordinates are in the range of the canvas
    # @param [ChunkyPNG::Point, Array, Hash, String] point_like The point to
    #   check.
    # @return [true, false] True if the x and y coordinates of the point are
    #   within the limits of this canvas.
    # @see ChunkyPNG.Point
    def include_point?(*point_like)
      dimension.include?(ChunkyPNG::Point(*point_like))
    end

    alias_method :include?,    :include_point?

    # Checks whether the given x- and y-coordinate are in the range of the
    # canvas
    #
    # @param [Integer] x The x-coordinate of the pixel (column)
    # @param [Integer] y The y-coordinate of the pixel (row)
    # @return [true, false] True if the x- and y-coordinate is in the range of
    #   this canvas.
    def include_xy?(x, y)
      y >= 0 && y < height && x >= 0 && x < width
    end

    # Checks whether the given y-coordinate is in the range of the canvas
    # @param [Integer] y The y-coordinate of the pixel (row)
    # @return [true, false] True if the y-coordinate is in the range of this
    #   canvas.
    def include_y?(y)
      y >= 0 && y < height
    end

    # Checks whether the given x-coordinate is in the range of the canvas
    # @param [Integer] x The y-coordinate of the pixel (column)
    # @return [true, false] True if the x-coordinate is in the range of this
    #   canvas.
    def include_x?(x)
      x >= 0 && x < width
    end

    # Returns the palette used for this canvas.
    # @return [ChunkyPNG::Palette] A palette which contains all the colors that
    #   are being used for this image.
    def palette
      ChunkyPNG::Palette.from_canvas(self)
    end

    # Equality check to compare this canvas with other matrices.
    # @param other The object to compare this Matrix to.
    # @return [true, false] True if the size and pixel values of the other
    #   canvas are exactly the same as this canvas's size and pixel values.
    def eql?(other)
      other.kind_of?(self.class) && other.pixels == self.pixels &&
            other.width == self.width && other.height == self.height
    end

    alias :== :eql?

    #################################################################
    # EXPORTING
    #################################################################

    # Creates an ChunkyPNG::Image object from this canvas.
    # @return [ChunkyPNG::Image] This canvas wrapped in an Image instance.
    def to_image
      ChunkyPNG::Image.from_canvas(self)
    end

    # Alternative implementation of the inspect method.
    # @return [String] A nicely formatted string representation of this canvas.
    # @private
    def inspect
      inspected = "<#{self.class.name} #{width}x#{height} ["
      for y in 0...height
        inspected << "\n\t[" << row(y).map { |p| ChunkyPNG::Color.to_hex(p) }.join(' ') << ']'
      end
      inspected << "\n]>"
    end

    protected

    # Replaces the image, given a new width, new height, and a new pixel array.
    def replace_canvas!(new_width, new_height, new_pixels)
      unless new_pixels.length == new_width * new_height
        raise ArgumentError, "The provided pixel array should have #{new_width * new_height} items"
      end
      @width, @height, @pixels = new_width, new_height, new_pixels
      self
    end

    # Throws an exception if the x-coordinate is out of bounds.
    def assert_x!(x)
      unless include_x?(x)
        raise ChunkyPNG::OutOfBounds, "Column index #{x} out of bounds!"
      end
      true
    end

    # Throws an exception if the y-coordinate is out of bounds.
    def assert_y!(y)
      unless include_y?(y)
        raise ChunkyPNG::OutOfBounds, "Row index #{y} out of bounds!"
      end
      true
    end

    # Throws an exception if the x- or y-coordinate is out of bounds.
    def assert_xy!(x, y)
      unless include_xy?(x, y)
        raise ChunkyPNG::OutOfBounds, "Coordinates (#{x},#{y}) out of bounds!"
      end
      true
    end

    # Throws an exception if the vector_length does not match this canvas'
    # height.
    def assert_height!(vector_length)
      if height != vector_length
        raise ChunkyPNG::ExpectationFailed,
          "The length of the vector (#{vector_length}) does not match the canvas height (#{height})!"
      end
      true
    end

    # Throws an exception if the vector_length does not match this canvas'
    # width.
    def assert_width!(vector_length)
      if width != vector_length
        raise ChunkyPNG::ExpectationFailed,
          "The length of the vector (#{vector_length}) does not match the canvas width (#{width})!"
      end
      true
    end

    # Throws an exception if the matrix width and height does not match this canvas' dimensions.
    def assert_size!(matrix_width, matrix_height)
      if width  != matrix_width
        raise ChunkyPNG::ExpectationFailed,
          'The width of the matrix does not match the canvas width!'
      end
      if height != matrix_height
        raise ChunkyPNG::ExpectationFailed,
          'The height of the matrix does not match the canvas height!'
      end
      true
    end
  end
end
