# Describes a single coordinate x,y Vector
class Vector2
  attr_reader :x, :y

  # @param [Integer] x: The pixel x coordinate
  # @param [Integer] y: The pixel y coordinate
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end

  def string
    "#{@x} #{@y}"
  end

  # Set the values for this Vector
  # @param [Integer] nx: The new x value
  # @param [Integer] ny: The new y value
  def set(nx, ny)
    @x = nx
    @y = ny
  end

  # Return true if this Vector is (0, 0)
  def zero?
    @x == 0 && @y == 0
  end

  # Zero out the vector
  def zero
    @x = 0
    @y = 0
  end

  # @param [Vector2] other_vector
  # @return [Vector2] new Vector instance with sum of the two Vector
  def add(other_vector)
    Vector2.new(@x + other_vector.x, @y + other_vector.y)
  end
end
