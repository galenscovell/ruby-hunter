require './module/colors'
require './module/constants'
require './module/tile_type'

# Describes a single Tile on the world grid
class Tile
  attr_reader :x, :y, :pixel_x, :pixel_y, :room_id, :hall_id

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
    @neighbor_states = [0] * Constants::NUM_TILE_STATES
    @state = TileType::EMPTY
  end

  def update_neighbor_states
    return unless @neighbors

    @neighbor_states = [0] * Constants::NUM_TILE_STATES
    @neighbors.each do |tile|
      @neighbor_states[tile.state] += 1
    end
  end

  # Get all neighbors of a certain state(s), or all if no states passed
  # @param [Array<Integer>] of_states: Only neighbors with these states, or all if nil
  # @return [Array<Tile>]
  def get_neighbors(of_states = nil)
    if of_states
      to_return = []
      @neighbors.each do |n|
        to_return.append(n) if n.one_of?(of_states)
      end

      return to_return
    end

    @neighbors
  end

  # Set the neighbors for this Tile
  # @param [Array<Tile>] neighbors: The neighbors to set
  def set_neighbors(neighbors)
    @neighbors = neighbors
  end

  def get_neighbor_states
    @neighbor_states
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

  ######################
  # TILE BECOME STATE
  ######################

  def become_empty
    @state = TileType::EMPTY
  end

  def become_floor
    @state = TileType::FLOOR
  end

  def become_wall
    @state = TileType::WALL
  end

  def become_corner
    @state = TileType::CORNER
  end

  def become_hall
    @state = TileType::HALL
  end

  def become_padding
    @state = TileType::PADDING
  end

  def become_water
    @state = TileType::WATER
  end
end
