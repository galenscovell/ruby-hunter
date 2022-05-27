require 'set'

# Describes a generated room composed of tiles
class Room
  attr_reader :room_id, :center_tile, :width, :height, :floor_tiles, :perimeter_tiles, :corner_tiles, :perimeter_w_corner_tiles, :halls

  # @param [Integer] room_id
  # @param [Tile] center_tile
  # @param [Integer] width
  # @param [Integer] height
  # @param [Array<Tile>] floor_tiles
  # @param [Array<Tile>] perimeter_tiles
  # @param [Array<Tile>] corner_tiles
  def initialize(
    room_id,
    center_tile,
    width,
    height,
    floor_tiles,
    perimeter_tiles,
    corner_tiles
  )
    @room_id = room_id
    @center_tile = center_tile
    @width = width
    @height = height
    @floor_tiles = floor_tiles
    @perimeter_tiles = perimeter_tiles
    @corner_tiles = corner_tiles

    @perimeter_wo_hall_tiles = @perimeter_tiles.dup
    @perimeter_w_corner_tiles = @perimeter_tiles.dup + @corner_tiles.dup

    @floor_tiles.each do |tile|
      tile.set_room(@room_id)
      tile.become_floor
    end

    @perimeter_tiles.each do |tile|
      tile.set_room(@room_id)
      tile.become_wall
    end

    @corner_tiles.each do |tile|
      tile.set_room(@room_id)
      tile.become_corner
    end

    @halls = Set.new
  end

  # Reset room perimeter, not including hall tiles
  def reset_perimeter
    @halls.each do |hall|
      @perimeter_wo_hall_tiles.delete(hall.start_tile) if @perimeter_wo_hall_tiles.include?(hall.start_tile)
    end

    @perimeter_tiles = @perimeter_wo_hall_tiles.dup
  end

  # Adds a new hall to this room
  # @param [Hall] hall
  def add_hall(hall)
    @halls.add(hall)
    hall.connecting_room_ids.add(@room_id)
  end
end
