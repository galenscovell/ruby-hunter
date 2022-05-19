require './model/point'
require './module/colors'
require './module/constants'
require './module/tile_type'

# Describes a single Tile on the world grid
class Tile
  attr_reader :x, :y, :pixel_x, :pixel_y
  attr_accessor :neighbors, :neighbor_states, :state, :room_id, :hall_id

  # @param [Integer] x: Grid X coordinate of the tile
  # @param [Integer] y: Grid Y coordinate of the tile
  def initialize(x, y)
    @x = x
    @y = y
    @pixel_x = x * (Constants::TILE_SIZE + Constants::MARGIN)
    @pixel_y = y * (Constants::TILE_SIZE + Constants::MARGIN)
    @room_id = -1
    @hall_id = -1
    @neighbors = []
    @neighbor_states = Array.new(Constants::NUM_TILE_STATES)
    @state = TileType::EMPTY
  end

  def set_neighbor_states
    @neighbor_states = Array.new(Constants::NUM_TILE_STATES)
    @neighbors.each do |neighbor|
      @neighbor_states[neighbor.state] += 1
    end
  end

  def in_room?
    @room_id != -1
  end

  def remove_room
    @room_id = -1
  end

  def in_hall?
    @hall_id != -1
  end

  def remove_hall
    @hall_id = -1
  end
end
