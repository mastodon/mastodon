module ChunkyPNG

  # Factory method for {ChunkyPNG::Vector} instances.
  #
  # @overload Vector(x0, y0, x1, y1, x2, y2, ...)
  #   Creates a vector by parsing two subsequent values in the argument list 
  #   as x- and y-coordinate of a point.
  #   @return [ChunkyPNG::Vector] The instantiated vector.
  # @overload Vector(string)
  #   Creates a vector by parsing coordinates from the input string.
  #   @return [ChunkyPNG::Vector] The instantiated vector.
  # @overload Vector(pointlike, pointlike, pointlike, ...)
  #   Creates a vector by converting every argument to a point using {ChunkyPNG.Point}.
  #   @return [ChunkyPNG::Vector] The instantiated vector.
  #
  # @return [ChunkyPNG::Vector] The vector created by this factory method.
  # @raise [ArgumentError] If the given arguments could not be understood as a vector.
  # @see ChunkyPNG::Vector
  def self.Vector(*args)
    
    return args.first if args.length == 1 && args.first.kind_of?(ChunkyPNG::Vector)
    
    if args.length == 1 && args.first.respond_to?(:scan)
      ChunkyPNG::Vector.new(ChunkyPNG::Vector.multiple_from_string(args.first)) # e.g. ['1,1 2,2 3,3']
    else
      ChunkyPNG::Vector.new(ChunkyPNG::Vector.multiple_from_array(args)) # e.g. [[1,1], [2,2], [3,3]] or [1,1,2,2,3,3]
    end
  end
  
  # Class that represents a vector of points, i.e. a list of {ChunkyPNG::Point} instances.
  #
  # Vectors can be created quite flexibly. See the {ChunkyPNG.Vector} factory methods for 
  # more information on how to construct vectors.
  class Vector
    
    include Enumerable
    
    # @return [Array<ChunkyPNG::Point>] The array that holds all the points in this vector.
    attr_reader :points
    
    # Initializes a vector based on a list of Point instances.
    #
    # You usually do not want to use this method directly, but call {ChunkyPNG.Vector} instead.
    #
    # @param [Array<ChunkyPNG::Point>] points
    # @see ChunkyPNG.Vector
    def initialize(points = [])
      @points = points
    end
    
    # Iterates over all the edges in this vector.
    #
    # An edge is a combination of two subsequent points in the vector. Together, they will form
    # a path from the first point to the last point
    #
    # @param [true, false] close Whether to close the path, i.e. return an edge that connects the last
    #   point in the vector back to the first point.
    # @return [void]
    # @raise [ChunkyPNG::ExpectationFailed] if the vector contains less than two points.
    # @see #edges
    def each_edge(close = true)
      raise ChunkyPNG::ExpectationFailed, "Not enough points in this path to draw an edge!" if length < 2
      points.each_cons(2) { |a, b| yield(a, b) }
      yield(points.last, points.first) if close
    end
    
    # Returns the point with the given indexof this vector.
    # @param [Integer] index The 0-based index of the point in this vector.
    # @param [ChunkyPNG::Point] The point instance.
    def [](index)
      points[index]
    end
    
    # Returns an enumerator that will iterate over all the edges in this vector.
    # @param (see #each_edge)
    # @return [Enumerator] The enumerator that iterates over the edges.
    # @raise [ChunkyPNG::ExpectationFailed] if the vector contains less than two points.
    # @see #each_edge
    def edges(close = true)
      to_enum(:each_edge, close)
    end
    
    # Returns the number of points in this vector.
    # @return [Integer] The length of the points array.
    def length
      points.length
    end
    
    # Iterates over all the points in this vector
    # @yield [ChunkyPNG::Point] The points in the correct order.
    # @return [void]
    def each(&block)
      points.each(&block)
    end
    
    # Comparison between two vectors for quality.
    # @param [ChunkyPNG::Vector] other The vector to compare with.
    # @return [true, false] true if the list of points are identical
    def eql?(other)
      other.points == points
    end
    
    alias_method :==, :eql?

    # Returns the range in x-coordinates for all the points in this vector.
    # @return [Range] The (inclusive) range of x-coordinates.
    def x_range
      Range.new(*points.map { |p| p.x }.minmax)
    end

    # Returns the range in y-coordinates for all the points in this vector.
    # @return [Range] The (inclusive) range of y-coordinates.
    def y_range
      Range.new(*points.map { |p| p.y }.minmax)
    end
    
    # Finds the lowest x-coordinate in this vector.
    # @return [Integer] The lowest x-coordinate of all the points in the vector.
    def min_x
      x_range.first
    end
    
    # Finds the highest x-coordinate in this vector.
    # @return [Integer] The highest x-coordinate of all the points in the vector.
    def max_x
      x_range.last
    end

    # Finds the lowest y-coordinate in this vector.
    # @return [Integer] The lowest y-coordinate of all the points in the vector.
    def min_y
      y_range.first
    end
    
    # Finds the highest y-coordinate in this vector.
    # @return [Integer] The highest y-coordinate of all the points in the vector.
    def max_y
      y_range.last
    end
    
    # Returns the offset from (0,0) of the minimal bounding box of all the
    # points in this vector
    # @return [ChunkyPNG::Point] A point that describes the top left corner if a
    #    minimal bounding box would be drawn around all the points in the vector.
    def offset
      ChunkyPNG::Point.new(min_x, min_y)
    end
    
    # Returns the width of the minimal bounding box of all the points in this vector.
    # @return [Integer] The x-distance between the points that are farthest from each other.
    def width
      1 + (max_x - min_x)
    end

    # Returns the height of the minimal bounding box of all the points in this vector.
    # @return [Integer] The y-distance between the points that are farthest from each other.
    def height
      1 + (max_y - min_y)
    end
    
    # Returns the dimension of the minimal bounding rectangle of the points in this vector.
    # @return [ChunkyPNG::Dimension] The dimension instance with the width and height 
    def dimension
      ChunkyPNG::Dimension.new(width, height)
    end
    
    # @return [Array<ChunkyPNG::Point>] The list of points interpreted from the input array.
    def self.multiple_from_array(source)
      return [] if source.empty?
      if source.first.kind_of?(Numeric) || source.first =~ /^\d+$/
        raise ArgumentError, "The points array is expected to have an even number of items!" if source.length % 2 != 0

        points = []
        source.each_slice(2) { |x, y| points << ChunkyPNG::Point.new(x, y) }
        return points
      else
        source.map { |p| ChunkyPNG::Point(p) }
      end
    end
    
    # @return [Array<ChunkyPNG::Point>] The list of points parsed from the string.
    def self.multiple_from_string(source_str)
      multiple_from_array(source_str.scan(/[\(\[\{]?(\d+)\s*[,x]?\s*(\d+)[\)\]\}]?/))
    end
  end
end
