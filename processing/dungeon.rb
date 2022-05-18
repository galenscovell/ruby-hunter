require 'gosu'

require './model/point'
require './model/tile'
require './module/colors'
require './module/constants'
require './module/tile_type'

# Procedurally generates a dungeon composed of rooms, halls and tiles
class Dungeon
  attr_accessor :room_map, :hall_map

  def initialize(pixel_width,
                 pixel_height,
                 target_rooms,
                 min_room_width,
                 max_room_width,
                 min_room_height,
                 max_room_height,
                 min_hall_length,
                 max_hall_length)
    @orthogonal_neighbors = [
      Point.new(0, 1),
      Point.new(1, 0),
      Point.new(0, -1),
      Point.new(-1, 0)
    ]

    @cols = pixel_width / (Constants::TILE_SIZE + Constants::MARGIN)
    @rows = pixel_height / (Constants::TILE_SIZE + Constants::MARGIN)
    @room_counter = 0
    @hall_counter = 0

    @target_rooms = target_rooms
    @min_room_width = min_room_width
    @max_room_width = max_room_width
    @min_room_height = min_room_height
    @max_room_height = max_room_height
    @min_hall_length = min_hall_length
    @max_hall_length = max_hall_length

    @room_map = {}
    @hall_map = {}
    @branchable_rooms = []
    @grid = construct_grid
    set_neighbors
  end

  # Safely attempt to get a Tile from the grid
  # @param [Integer] x
  # @param [Integer] y
  def get_tile(x, y)
    @grid[x][y] if x > -1 && x < @cols && y > -1 && y < @rows
    nil
  end

  # Construct the base Tile grid for the dungeon
  def construct_grid
    grid = Array.new(@cols) { Array.new(@rows) }
    (0...@cols).each do |x|
      (0...@rows).each do |y|
        grid[x][y] = Tile.new(x, y)
      end
    end

    grid
  end

  # Set the 4 orthogonal neighbors for each Tile in the grid
  def set_neighbors
    (0...@cols).each do |x|
      (0...@rows).each do |y|
        tile = @grid[x][y]
        tile_pos = Point.new(tile.x, tile.y)
        theoretical_neighbors = [
          tile_pos.add(@orthogonal_neighbors[0]),
          tile_pos.add(@orthogonal_neighbors[1]),
          tile_pos.add(@orthogonal_neighbors[2]),
          tile_pos.add(@orthogonal_neighbors[3])
        ]

        neighbors = []
        theoretical_neighbors.each do |neighbor|
          neighbor_tile = get_tile(neighbor.x, neighbor.y)
          neighbors.add(neighbor_tile) if neighbor_tile
        end

        tile.neighbors = neighbors
      end
    end
  end

  # Update the neighbor states for all Tiles in the grid
  def update_neighbors
    (0...@cols).each do |x|
      (0...@rows).each do |y|
        tile = @grid[x][y]
        tile.set_neighbor_states
      end
    end
  end

  # Render the generated dungeon as it currently is
  def render
    (0...@cols).each do |x|
      (0...@rows).each do |y|
        tile = @grid[x][y]
        case tile.state
        when TileType::EMPTY
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::EMPTY)
        when TileType::FLOOR
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::FLOOR)
        when TileType::WALL
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::WALL)
        when TileType::CORNER
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::CORNER)
        when TileType::HALL
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::HALL)
        when TileType::PADDING
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::PADDING)
        when TileType::WATER
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::WATER)
        else
          # type code here
        end
      end
    end
  end
end
