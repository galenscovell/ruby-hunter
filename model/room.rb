require 'set'

require './module/constants'
require './module/tile_type'

# Describes a generated room composed of tiles
class Room
  attr_reader :room_id, :center_tile, :width, :height,
              :inner_tiles, :corner_tiles, :perimeter_w_corners, :halls
  attr_accessor :perimeter_tiles

  # @param [Integer] room_id
  # @param [Tile] center_tile
  # @param [Integer] width
  # @param [Integer] height
  # @param [Array<Tile>] non_perimeter_tiles
  # @param [Array<Tile>] perimeter_tiles
  # @param [Array<Tile>] corner_tiles
  def initialize(room_id,
                 center_tile,
                 width,
                 height,
                 non_perimeter_tiles,
                 perimeter_tiles,
                 corner_tiles)
    @room_id = room_id
    @center_tile = center_tile
    @width = width
    @height = height
    @inner_tiles = non_perimeter_tiles.dup
    @perimeter_tiles = perimeter_tiles.dup
    @corner_tiles = corner_tiles.dup
    @halls = Set.new
    @perimeter_wo_halls = @perimeter_tiles.dup
    @perimeter_w_corners = perimeter_tiles + corner_tiles

    @inner_tiles.each do |tile|
      tile.room_id = @room_id
      tile.state = TileType::FLOOR
    end

    @perimeter_tiles.each do |tile|
      tile.room_id = @room_id
      tile.state = TileType::WALL
    end

    @corner_tiles.each do |tile|
      tile.room_id = @room_id
      tile.state = TileType::CORNER
    end
  end

  # Reset room perimeter, not including hall tiles
  def reset_perimeter
    @halls.each do |hall|
      if @perimeter_wo_halls.include? hall.start_tile
        @perimeter_wo_halls.delete(hall.start_tile)
      end
    end

    @perimeter_tiles = @perimeter_wo_halls.dup
  end

  # Adds a new hall to this room
  # @param [Hall] hall
  def add_hall(hall)
    @halls.add(hall)
    hall.connecting_room_ids.add(@room_id)
  end
end
