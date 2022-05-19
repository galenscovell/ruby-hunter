require 'gosu'

require './model/hall'
require './model/point'
require './model/room'
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
    build_initial_hall
  end

  # Build initial Hall out from central perimeter
  def build_initial_hall
    center_col = (@cols - 1) / 2
    center_row = (@rows - 1) / 2
    col_range = @cols / 3
    row_range = @rows / 3

    col_min = center_col - col_range
    col_max = center_col + col_range
    row_min = center_row - row_range
    row_max = center_row + row_range

    center_perimeter_tiles = Array.new
    (0...@cols).each do |x|
      (0...@rows).each do |y|
        tile = @grid[x][y]

        # Set entire perimeter as padding to not be used later
        if tile.x == 0 || tile.x == (@cols - 1) || tile.y == 0 || tile.y == (@rows - 1)
          tile.state = TileType::PADDING

          # Set central tiles as usable for the start Hall
          if (tile.x > col_min && tile.x < col_max) || (tile.y > row_min && tile.y < row_max)
            center_perimeter_tiles.append(tile)
          end
        end
      end
    end

    hall_built = false
    while !hall_built && center_perimeter_tiles.count > 0
      random_tile = center_perimeter_tiles.sample
      center_perimeter_tiles.delete(random_tile)

      tiles, direction = try_hall(random_tile)
      if direction != [0,0]
        if end_hall_with_room(tiles, direction)
          hall_built = true
        end
      end
    end
  end

  # Build a Hall out from a Tile in the empty direction from it
  # Return list of Hall Tiles and its vector direction
  # If Hall is not viable, return null Tiles and empty vector
  # @param [Tile] start_tile
  def try_hall(start_tile)
    # Find direction of Hall by locating which direction is empty/padding
    hall_dir = [0,0]
    @orthogonal_neighbors.shuffle
    @orthogonal_neighbors.each do |coord|
      tile = get_tile(start_tile.x + coord.x, start_tile.y + coord.y)
      if tile && (tile.state == TileType::EMPTY || tile.state == TileType::PADDING)
        hall_dir = [coord.x, coord.y]
        break
      end
    end

    # No empty direction for this Tile
    if hall_dir == [0,0]
      [[], [0,0]]
    end

    # Find Tiles that would compose Hall
    hall_len = rand(@min_hall_length..@max_hall_length)
    hall_tiles = Array.new
    curr_tile = start_tile
    (0..hall_len).each do |n|
      curr_tile = get_tile(curr_tile.x + hall_dir[0], curr_tile.y + hall_dir[1])
      if !curr_tile || !(curr_tile.state == TileType::EMPTY || curr_tile.state == TileType::PADDING)
        [[], [0,0]]
      end

      hall_tiles.append(curr_tile)
    end

    if hall_tiles.count > 0
      [hall_tiles, hall_dir]
    else
      [[], [0,0]]
    end
  end

  # If Hall was viable, continue to attempt to build room at end of it
  # If Room is also viable, finalize both and return true
  # @param [Array<Tile>] hall_tiles
  # @param [Array<Integer>] hall_dir
  # @return [Boolean] True if Hall and Room were successfully built
  def end_hall_with_room(hall_tiles, hall_dir)
    start_tile = hall_tiles[0]
    end_tile = hall_tiles[-1]

    room = build_room(end_tile, hall_dir)
    if room
      new_hall = Hall.new(@hall_counter, hall_tiles)
      @hall_counter += 1

      if @room_map.include? start_tile.room_id
        @room_map[start_tile.room_id].add_hall(new_hall)
      end

      @branchable_rooms.append(room)
      unless @hall_map.include? new_hall.hall_id
        @hall_map[new_hall.hall_id] = new_hall
      end

      true
    end

    false
  end

  # Build a room at the end of a Hall. If viable return it, otherwise null
  # @param [Tile] hall_end_tile
  # @param [Array<Integer>] hall_dir
  def build_room(hall_end_tile, hall_dir)
    room_width = rand(@min_room_width..@max_room_width)
    room_height = rand(@min_room_height..@max_room_height)
    center_tile = get_tile(hall_end_tile.x + hall_dir[0] * room_width,
                           hall_end_tile.y + hall_dir[1] * room_height)

    # Center Tile not viable
    unless center_tile
      nil
    end

    room = try_quad_room(center_tile, room_width, room_height)
    unless room
      nil
    end

    pad_room(room)
    @room_map[room.room_id] = room
    room
  end

  # Attempt to build out a room starting from a center tile with specified dimensions
  # @param [Tile] center_tile
  # @param [Integer] room_width
  # @param [Integer] room_height
  def try_quad_room(center_tile, room_width, room_height)
    floor_tiles = Set.new
    perimeter_tiles = Set.new
    corner_tiles = Set.new

    (-room_width...room_width).each do |dx|
      (-room_height...room_height).each do |dy|
        tile = get_tile(center_tile.x + dx, center_tile.y + dy)
        if !tile || tile.state != TileType::EMPTY
          nil
        end

        # Find perimeter
        if dx.abs == room_width || dx.abs == room_height
          # Set corner Tiles, handled differently downstream
          if dx.abs == room_width && dy.abs == room_height
            corner_tiles.add(tile)
          else
            perimeter_tiles.add(tile)
          end
        else
          floor_tiles.add(tile)
        end
      end
    end

    room = Room.new(@room_counter,
                    center_tile,
                    room_width,
                    room_height,
                    Array(floor_tiles),
                    Array(perimeter_tiles),
                    Array(corner_tiles))
    @room_counter += 1
    room
  end

  # Add a two Tile border of padding around created Room so they
  # aren't built touching each other
  # @param [Room] room
  def pad_room(room)
    room.perimeter_w_corners.each do |corner|
      corner.neighbors.each do |neighbor|
        if neighbor.state == TileType::EMPTY
          neighbor.state == TileType::PADDING
          neighbor.neighbors.each do |sub_neighbor|
            if sub_neighbor.state == TileType::EMPTY
              sub_neighbor.state == TileType::PADDING
            end
          end
        end
      end
    end
  end

  # Safely attempt to get a Tile from the grid
  # @param [Integer] x
  # @param [Integer] y
  def get_tile(x, y)
    if x > -1 && x < @cols && y > -1 && y < @rows
      @grid[x][y]
    else
      nil
    end
  end

  # Construct the base Tile grid for the dungeon
  # @return [Array<Array<Tile>>] grid
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

        neighbors = Array.new
        theoretical_neighbors.each do |coord|
          neighbor_tile = get_tile(coord.x, coord.y)
          neighbors.append(neighbor_tile) if neighbor_tile
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
