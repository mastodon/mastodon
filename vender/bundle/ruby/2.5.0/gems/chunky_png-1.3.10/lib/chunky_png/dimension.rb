module ChunkyPNG

  # Creates a {ChunkyPNG::Dimension} instance using arguments that can be interpreted
  # as width and height.
  #
  # @overload Dimension(width, height)
  #   @param [Integer] width The width-component of the dimension.
  #   @param [Integer] height The height-component of the dimension.
  #   @return [ChunkyPNG::Dimension] The instantiated dimension.
  #
  # @overload Dimension(string)
  #   @param [String] string A string from which a width and height value can be parsed, e.g.
  #      <tt>'10x20'</tt> or <tt>'[10, 20]'</tt>.
  #   @return [ChunkyPNG::Dimension] The instantiated dimension.
  #
  # @overload Dimension(ary)
  #   @param [Array] ary An array with the desired width as first element and the
  #      desired height as second element, e.g. <tt>[10, 20]</tt>.
  #   @return [ChunkyPNG::Dimension] The instantiated dimension.
  #
  # @overload Dimension(hash)
  #   @param [Hash] hash An hash with a <tt>'height'</tt> or <tt>:height</tt> key for the
  #      desired height and with a <tt>'width'</tt> or <tt>:width</tt> key for the desired
  #      width.
  #   @return [ChunkyPNG::Dimension] The instantiated dimension.
  #
  # @return [ChunkyPNG::Dimension] The dimension created by this factory method.
  # @raise [ArgumentError] If the argument(s) given where not understood as a dimension.
  # @see ChunkyPNG::Dimension
  def self.Dimension(*args)
    case args.length
    when 2; ChunkyPNG::Dimension.new(*args)
    when 1; build_dimension_from_object(args.first)
    else raise ArgumentError,
      "Don't know how to construct a dimension from #{args.inspect}"
    end
  end

  def self.build_dimension_from_object(source)
    case source
    when ChunkyPNG::Dimension
      source
    when ChunkyPNG::Point
      ChunkyPNG::Dimension.new(source.x, source.y)
    when Array
      ChunkyPNG::Dimension.new(source[0], source[1])
    when Hash
      width = source[:width] || source['width']
      height = source[:height] || source['height']
      ChunkyPNG::Dimension.new(width, height)
    when ChunkyPNG::Dimension::DIMENSION_REGEXP
      ChunkyPNG::Dimension.new($1, $2)
    else
      if source.respond_to?(:width) && source.respond_to?(:height)
        ChunkyPNG::Dimension.new(source.width, source.height)
      else
        raise ArgumentError, "Don't know how to construct a dimension from #{source.inspect}!"
      end
    end
  end
  private_class_method :build_dimension_from_object

  # Class that represents the dimension of something, e.g. a {ChunkyPNG::Canvas}.
  #
  # This class contains some methods to simplify performing dimension related checks.
  class Dimension

    # @return [Regexp] The regexp to parse dimensions from a string.
    # @private
    DIMENSION_REGEXP = /^[\(\[\{]?(\d+)\s*[x,]?\s*(\d+)[\)\]\}]?$/

    # @return [Integer] The width-component of this dimension.
    attr_accessor :width

    # @return [Integer] The height-component of this dimension.
    attr_accessor :height

    # Initializes a new dimension instance.
    # @param [Integer] width The width-component of the new dimension.
    # @param [Integer] height The height-component of the new dimension.
    def initialize(width, height)
      @width, @height = width.to_i, height.to_i
    end

    # Returns the area of this dimension.
    # @return [Integer] The area in number of pixels.
    def area
      width * height
    end

    # Checks whether a point is within bounds of this dimension.
    # @param [ChunkyPNG::Point, ...] A point-like to bounds-check.
    # @return [true, false] True iff the x and y coordinate fall in this dimension.
    # @see ChunkyPNG.Point
    def include?(*point_like)
      point = ChunkyPNG::Point(*point_like)
      point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    end

    # Checks whether 2 dimensions are identical.
    # @param [ChunkyPNG::Dimension] The dimension to compare with.
    # @return [true, false] <tt>true</tt> iff width and height match.
    def eql?(other)
      return false unless other.respond_to?(:width) && other.respond_to?(:height)
      other.width == width && other.height == height
    end

    alias_method :==, :eql?

    # Compares the size of 2 dimensions.
    # @param [ChunkyPNG::Dimension] The dimension to compare with.
    # @return [-1, 0, 1] -1 if the other dimension has a larger area, 1 of this
    #   dimension is larger, 0 if both are identical in size.
    def <=>(other)
      other.area <=> area
    end

    # Casts this dimension into an array.
    # @return [Array<Integer>] <tt>[width, height]</tt> for this dimension.
    def to_a
      [width, height]
    end

    alias_method :to_ary, :to_a
  end
end
