# Describes a single coordinate x,y point
class Point
  attr_reader :x, :y

  # @param [Integer] x: The pixel x coordinate
  # @param [Integer] y: The pixel y coordinate
  def initialize(x, y)
    @x = x
    @y = y
  end

  def string
    "#{@x} #{@y}"
  end

  # @param [Point] other_point
  # @return [Point] new Point instance with sum of the two points
  def add(other_point)
    Point.new(@x + other_point.x, @y + other_point.y)
  end
end
