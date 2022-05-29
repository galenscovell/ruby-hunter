require 'set'

require './module/tile_type'

# Describes an instance of a hall, which connects rooms
class Hall
  attr_reader :hall_id, :start_tile, :end_tile, :tiles, :connecting_room_ids

  # @param [Integer] hall_id
  # @param [Array<Tile>] tiles
  # @param [Grid] grid
  def initialize(hall_id, tiles, grid)
    @hall_id = hall_id
    @connecting_room_ids = Set.new
    @start_tile = tiles[0]
    @end_tile = tiles[-1]
    @tiles = tiles

    check_states = [TileType::EMPTY, TileType::PADDING, TileType::CORNER]
    @tiles.each do |tile|
      tile.set_hall(@hall_id)
      tile.become_hall

      grid.get_neighbors(tile, check_states).each do |neighbor|
        neighbor.set_hall(@hall_id)
        neighbor.become_wall
      end
    end
  end
end
