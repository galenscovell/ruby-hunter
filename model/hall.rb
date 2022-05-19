require 'set'

require './module/tile_type'

# Describes an instance of a hall, which connects rooms
class Hall
  attr_reader :hall_id, :start_tile, :end_tile, :tiles, :connecting_room_ids

  # @param [Integer] hall_id
  # @param [Array<Tile>] tiles
  def initialize(hall_id, tiles)
    @hall_id = hall_id
    @connecting_room_ids = Set.new
    @start_tile = tiles[0]
    @end_tile = tiles[-1]
    @tiles = tiles

    check_states = [TileType::EMPTY, TileType::PADDING, TileType::CORNER]
    @tiles.each do |tile|
      tile.hall_id = @hall_id
      tile.state = TileType::HALL

      tile.neighbors.each do |neighbor|
        if check_states.include? neighbor.state
          neighbor.hall_id = @hall_id
          neighbor.state = TileType::WALL
        end
      end
    end
  end
end
