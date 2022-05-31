require 'gosu'

require './module/colors'
require './module/constants'
require './module/tile_type'

# Describes a single Tile on the world grid
class Tile
  attr_reader :x, :y, :room_id, :hall_id

  # @param [Integer] x: Grid X coordinate of the tile
  # @param [Integer] y: Grid Y coordinate of the tile
  def initialize(x, y)
    @x = x
    @y = y
    @pixel_x = x * (Constants::TILE_SIZE + Constants::MARGIN)
    @pixel_y = y * (Constants::TILE_SIZE + Constants::MARGIN)
    @room_id = -1
    @hall_id = -1
    @state = TileType::EMPTY
    @frame = 0
    @color = Colors::EMPTY

    become_empty
  end

  def to_str
    "#{@x}, #{@y}"
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  ######################
  # ROOM STATE
  ######################

  def in_room?
    @room_id != -1
  end

  def set_room(room_id)
    @room_id = room_id
  end

  def remove_room
    @room_id = -1
  end

  ######################
  # HALL STATE
  ######################

  def in_hall?
    @hall_id != -1
  end

  def set_hall(hall_id)
    @hall_id = hall_id
  end

  def remove_hall
    @hall_id = -1
  end

  ######################
  # TILE CURRENT STATE
  ######################

  # Check if this Tile is in one of passed states
  # @param [Array<Integer>] states: The states to check for
  # @return True if Tile is currently one of the passed states
  def one_of?(states)
    states.include?(@state)
  end

  def empty?
    @state == TileType::EMPTY
  end

  def floor?
    @state == TileType::FLOOR
  end

  def wall?
    @state == TileType::WALL
  end

  def corner?
    @state == TileType::CORNER
  end

  def hall?
    @state == TileType::HALL
  end

  def padding?
    @state == TileType::PADDING
  end

  def water?
    @state == TileType::WATER
  end

  def start?
    @state == TileType::START_POINT
  end

  def end?
    @state == TileType::END_POINT
  end

  def explored?
    @state == TileType::EXPLORED
  end

  ######################
  # TILE BECOME STATE
  ######################

  def become_empty
    @state = TileType::EMPTY
    @color = Colors::EMPTY
  end

  def become_floor
    @state = TileType::FLOOR
    @color = Colors::FLOOR.sample
  end

  def become_wall
    @state = TileType::WALL
    @color = Colors::WALL.sample
  end

  def become_corner
    @state = TileType::CORNER
    @color = Colors::WALL.sample
  end

  def become_hall
    @state = TileType::HALL
    # @color = Colors::HALL
    @color = Colors::FLOOR.sample
  end

  def become_padding
    @state = TileType::PADDING
    # @color = Colors::PADDING
    @color = Colors::EMPTY
  end

  def become_perimeter
    @state = TileType::PADDING
    @color = Colors::PERIMETER
  end

  def become_water
    @state = TileType::WATER
    @color = Colors::WATER
  end

  def become_start_point
    @state = TileType::START_POINT
    @color = Colors::ENDPOINT
  end

  def become_end_point
    @state = TileType::END_POINT
    @color = Colors::ENDPOINT
  end

  def become_explored
    @frame = 45
    @state = TileType::EXPLORED
    @color = Gosu::Color::WHITE
  end

  def become_path
    @state = TileType::PATH
    @color = Colors::PATH
  end

  def update
    return unless explored? && @frame.positive?

    @frame -= 1
    @color = lerp_color(Colors::EXPLORE_START, Colors::EXPLORE_END)
  end

  def draw
    update
    Gosu.draw_rect(@pixel_x, @pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, @color)
  end

  # @param [Color] color_1
  # @param [Color] color_2
  def lerp_color(color_1, color_2)
    t = 1.0 - (@frame / 60.0)
    r = color_1.red + (color_2.red - color_1.red) * t
    g = color_1.green + (color_2.green - color_1.green) * t
    b = color_1.blue + (color_2.blue - color_1.blue) * t
    Gosu::Color.rgba(r, g, b, 255)
  end
end
