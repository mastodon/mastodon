module ChunkyPNG
  
  # Factory method to create {ChunkyPNG::Point} instances.
  # 
  # This method tries to be as flexible as possible with regards to the given input: besides 
  # explicit coordinates, this method also accepts arrays, hashes, strings, {ChunkyPNG::Dimension}
  # instances and anything that responds to <tt>:x</tt> and <tt>:y</tt>.
  # 
  # @overload Point(x, y)
  #   @param [Integer, :to_i] x The x-coordinate
  #   @param [Integer, :to_i] y The y-coordinate
  #   @return [ChunkyPNG::Point] The instantiated point.
  #
  # @overload Point(array)
  #   @param [Array<Integer>] array A two element array which represent the x- and y-coordinate.
  #   @return [ChunkyPNG::Point] The instantiated point.
  #
  # @overload Point(hash)
  #   @param [Hash] array A hash with the <tt>:x</tt> or <tt>'x'</tt> and <tt>:y</tt> or
  #     <tt>'y'</tt> keys set, which will be used as coordinates.
  #   @return [ChunkyPNG::Point] The instantiated point.
  #
  # @overload Point(string)
  #   @param [String] string A string that contains the coordinates, e.g. <tt>'0, 4'</tt>,
  #     <tt>'(0 4)'</tt>, <tt>[0,4}'</tt>, etc.
  #   @return [ChunkyPNG::Point] The instantiated point.
  #
  # @return [ChunkyPNG::Point]
  # @raise [ArgumentError] if the arguments weren't understood.
  # @see ChunkyPNG::Point
  def self.Point(*args)
    case args.length
    when 2; ChunkyPNG::Point.new(*args)
    when 1; build_point_from_object(args.first)
    else raise ArgumentError, 
      "Don't know how to construct a point from #{args.inspect}!"
    end 
  end

  def self.build_point_from_object(source)
    case source
    when ChunkyPNG::Point
      source
    when ChunkyPNG::Dimension
      ChunkyPNG::Point.new(source.width, source.height)
    when Array
      ChunkyPNG::Point.new(source[0], source[1])
    when Hash
      x = source[:x] || source['x']
      y = source[:y] || source['y']
      ChunkyPNG::Point.new(x, y)
    when ChunkyPNG::Point::POINT_REGEXP
      ChunkyPNG::Point.new($1.to_i, $2.to_i)
    else 
      if source.respond_to?(:x) && source.respond_to?(:y)
        ChunkyPNG::Point.new(source.x, source.y)
      else 
        raise ArgumentError, 
          "Don't know how to construct a point from #{source.inspect}!"
      end
    end
  end
  private_class_method :build_point_from_object

  # Simple class that represents a point on a canvas using an x and y coordinate.
  #
  # This class implements some basic methods to handle comparison, the splat operator and
  # bounds checking that make it easier to work with coordinates.
  #
  # @see ChunkyPNG.Point
  class Point
    
    # @return [Regexp] The regexp to parse points from a string.
    # @private
    POINT_REGEXP = /^[\(\[\{]?(\d+)\s*[,]?\s*(\d+)[\)\]\}]?$/

    # @return [Integer] The x-coordinate of the point.
    attr_accessor :x

    # @return [Integer] The y-coordinate of the point.
    attr_accessor :y
    
    # Initializes a new point instance.
    # @param [Integer, :to_i] x The x-coordinate.
    # @param [Integer, :to_i] y The y-coordinate.
    def initialize(x, y)
      @x, @y = x.to_i, y.to_i
    end
    
    # Checks whether 2 points are identical.
    # @return [true, false] <tt>true</tt> iff the x and y coordinates match
    def eql?(other)
      other.x == x && other.y == y
    end
    
    alias_method :==, :eql?
    
    # Compares 2 points.
    #
    # It will first compare the y coordinate, and it only takes the x-coordinate into
    # account if the y-coordinates of the points are identical. This way, an array of
    # points will be sorted into the order in which they would occur in the pixels
    # array returned by {ChunkyPNG::Canvas#pixels}.
    #
    # @param [ChunkyPNG::Point] other The point to compare this point with.
    # @return [-1, 0, 1] <tt>-1</tt> If this point comes before the other one, <tt>1</tt>
    #   if after, and <tt>0</tt> if the points are identical.
    def <=>(other)
      ((y <=> other.y) == 0) ? x <=> other.x : y <=> other.y
    end
    
    # Converts the point instance to an array.
    # @return [Array] A 2-element array, i.e. <tt>[x, y]</tt>.
    def to_a
      [x, y]
    end
    
    alias_method :to_ary, :to_a
    
    # Checks whether the point falls into a dimension
    # @param [ChunkyPNG::Dimension, ...] dimension_like The dimension of which the bounds 
    #   should be taken for the check.
    # @return [true, false] <tt>true</tt> iff the x and y coordinate fall width the width 
    #   and height of the dimension.
    def within_bounds?(*dimension_like)
      ChunkyPNG::Dimension(*dimension_like).include?(self)
    end
  end
end
