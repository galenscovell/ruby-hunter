require 'set'

require './model/grid'
require './model/hall'
require './model/room'
require './model/tile'
require './model/vector2'
require './module/tile_type'

# Procedurally generates a dungeon composed of rooms, halls and tiles
class Dungeon
  attr_accessor :room_map, :hall_map
  attr_reader :grid, :rows, :cols, :progress_pct

  def initialize(
    pixel_width:,
    pixel_height:,
    target_rooms:,
    min_room_width:,
    max_room_width:,
    min_room_height:,
    max_room_height:,
    min_hall_length:,
    max_hall_length:
  )
    @room_counter = 1
    @hall_counter = 1

    @target_rooms = target_rooms
    @min_room_width = min_room_width
    @max_room_width = max_room_width
    @min_room_height = min_room_height
    @max_room_height = max_room_height
    @min_hall_length = min_hall_length
    @max_hall_length = max_hall_length

    @progress_pct = 0.0
    @progress_pct_per_room = 1.0 / @target_rooms

    @room_map = {}
    @hall_map = {}
    @branchable_rooms = []

    @grid = Grid.new(pixel_width, pixel_height)
    build_initial_hall
  end

  # Attempt to build a new room branching off of a previously built one
  # @return [Boolean] return False when no more can be built or target amount reached
  def work_remains
    if @room_counter == @target_rooms || @branchable_rooms.count.zero?
      @progress_pct = 1.0
      return false
    end

    random_room = @branchable_rooms.sample
    return unless random_room

    if random_room.perimeter_tiles.count.zero?
      @branchable_rooms.delete(random_room)
      random_room.reset_perimeter
      return true
    end

    random_perimeter_tile = random_room.perimeter_tiles.sample
    random_room.perimeter_tiles.delete(random_perimeter_tile)

    tiles, direction = try_hall(random_perimeter_tile)
    if !direction.zero? && end_hall_with_room(tiles, direction)
      @room_counter += 1
      @progress_pct += @progress_pct_per_room
    end

    true
  end

  # Build initial Hall out from central perimeter
  def build_initial_hall
    center_perimeter_tiles = @grid.find_central_perimeter_tiles

    hall_built = false
    while !hall_built && center_perimeter_tiles.count.positive?
      random_tile = center_perimeter_tiles.sample
      next unless random_tile

      center_perimeter_tiles.delete(random_tile)

      tiles, direction = try_hall(random_tile)
      next if direction.zero?

      hall_built = true if end_hall_with_room(tiles, direction)
    end
  end

  # Build a Hall out from a Tile in the empty direction from it
  # Return list of Hall Tiles and its vector direction
  # If Hall is not viable, return null Tiles and empty vector
  # @param [Tile] start_tile
  # @return [[Array<Tile>, Vector2]]
  def try_hall(start_tile)
    # Find direction of Hall by locating which direction is empty/padding
    hall_dir = Vector2.new
    @grid.orthogonal.shuffle

    check_states = [TileType::EMPTY, TileType::PADDING]

    @grid.orthogonal.each do |vector|
      tile = @grid.get_tile(start_tile.x + vector.x, start_tile.y + vector.y)
      if tile&.one_of?(check_states)
        hall_dir.set(vector.x, vector.y)
        break
      end
    end

    # No usable direction for this Tile
    return [[], hall_dir] if hall_dir.zero?

    # Find Tiles that would compose Hall
    hall_len = rand(@min_hall_length..@max_hall_length)
    hall_tiles = Array[start_tile]
    curr_tile = start_tile

    (0..hall_len).each do
      curr_tile = @grid.get_tile(curr_tile.x + hall_dir.x, curr_tile.y + hall_dir.y)
      return [[], Vector2.new] if !curr_tile || !curr_tile.one_of?(check_states)

      hall_tiles.append(curr_tile)
    end

    return [hall_tiles, hall_dir] if hall_tiles.count.positive?

    [[], Vector2.new]
  end

  # If Hall was viable, continue to attempt to build room at end of it
  # If Room is also viable, finalize both and return true
  # @param [Array<Tile>] hall_tiles
  # @param [Vector2] hall_dir
  # @return [Boolean] True if Hall and Room were successfully built
  def end_hall_with_room(hall_tiles, hall_dir)
    start_tile = hall_tiles.first
    end_tile = hall_tiles.last
    return false if !start_tile || !end_tile

    room = build_room(end_tile, hall_dir)
    if room
      new_hall = Hall.new(@hall_counter, hall_tiles, @grid)
      room.add_hall(new_hall)
      @hall_counter += 1

      @room_map[start_tile.room_id].add_hall(new_hall) if @room_map.include?(start_tile.room_id)

      @branchable_rooms.append(room)
      @hall_map[new_hall.hall_id] = new_hall unless @hall_map.include?(new_hall.hall_id)

      return true
    end

    false
  end

  # Build a room at the end of a Hall. If viable return it, otherwise null
  # @param [Tile] hall_end_tile
  # @param [Vector2] hall_dir
  def build_room(hall_end_tile, hall_dir)
    room_width = rand(@min_room_width..@max_room_width)
    room_height = rand(@min_room_height..@max_room_height)
    center_tile = @grid.get_tile(
      hall_end_tile.x + hall_dir.x * room_width,
      hall_end_tile.y + hall_dir.y * room_height
    )

    # Center Tile not viable
    return nil unless center_tile

    room = try_quad_room(center_tile, room_width, room_height)
    return nil unless room

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

    (-room_width..room_width).each do |dx|
      (-room_height..room_height).each do |dy|
        tile = @grid.get_tile(center_tile.x + dx, center_tile.y + dy)

        return nil if !tile || !tile.empty?

        # Find perimeter
        if dx.abs == room_width || dy.abs == room_height
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

    Room.new(
      @room_counter,
      center_tile,
      room_width,
      room_height,
      Array(floor_tiles),
      Array(perimeter_tiles),
      Array(corner_tiles)
    )
  end

  # Add a two Tile border of padding around created Room so they
  # aren't built touching each other
  # @param [Room] room
  def pad_room(room)
    check_states = [TileType::EMPTY]

    room.perimeter_w_corner_tiles.each do |corner|
      @grid.get_neighbors(corner, check_states).each do |neighbor|
        neighbor.become_padding
        @grid.get_neighbors(neighbor, check_states).each(&:become_padding)
      end
    end
  end
end
