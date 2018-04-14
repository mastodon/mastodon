$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'equatable'

class Point
  include Equatable

  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end
end

class ColorPoint < Point
  attr_reader :color

  def initialize(x, y, color)
    super(x, y)
    @color = color
  end
end

point_1 = Point.new(1, 1)
point_2 = Point.new(1, 1)
point_3 = Point.new(2, 1)

puts point_1 == point_2
puts point_1.hash == point_2.hash
puts point_1.eql?(point_2)
puts point_1.equal?(point_2)

puts point_1 == point_3
puts point_1.hash == point_3.hash
puts point_1.eql?(point_3)
puts point_1.equal?(point_3)

puts point_1.inspect

point = Point.new(1, 1)
color_point = ColorPoint.new(1, 1, :red)

puts 'Subtypes'
puts point == color_point
puts color_point == point
puts point.hash == color_point.hash
puts point.eql?(color_point)
puts point.equal?(color_point)
