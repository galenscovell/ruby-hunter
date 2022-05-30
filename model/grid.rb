require './model/tile'
require './module/constants'

# Defines a 2D array of Tiles corresponding to a grid.
class Grid
  include Enumerable

  attr_reader :orthogonal

  # @param [Integer] pixel_width
  # @param [Integer] pixel_height
  def initialize(pixel_width, pixel_height)
    @cols = pixel_width / (Constants::TILE_SIZE + Constants::MARGIN)
    @rows = pixel_height / (Constants::TILE_SIZE + Constants::MARGIN)

    @elements = Array.new(@cols * @rows)
    (0...@rows).each do |y|
      (0...@cols).each do |x|
        @elements[generate_index(x, y)] = Tile.new(x, y)
      end
    end

    @neighbors = Array.new(@elements.length)
    @orthogonal = [
      Vector2.new(0, 1),
      Vector2.new(1, 0),
      Vector2.new(0, -1),
      Vector2.new(-1, 0)
    ]

    set_neighbors
  end

  # Get the single array index for a 2D array coordinate
  def generate_index(x, y)
    (y * @cols) + x
  end

  # Iterate across all Tiles in grid, doing something with each one.
  def each(&block)
    @elements.each(&block)
  end

  # Safely attempt to get a Tile from the grid
  # @param [Integer] x
  # @param [Integer] y
  def get_tile(x, y)
    @elements[generate_index(x, y)] if x >= 0 && x < @cols && y >= 0 && y < @rows
  end

  # Set the 4 orthogonal neighbors for each Tile in the grid
  def set_neighbors
    each do |tile|
      tile_pos = Vector2.new(tile.x, tile.y)
      theoretical_neighbors = [
        tile_pos.add(@orthogonal[0]),
        tile_pos.add(@orthogonal[1]),
        tile_pos.add(@orthogonal[2]),
        tile_pos.add(@orthogonal[3])
      ]

      neighbors = []
      theoretical_neighbors.each do |coord|
        neighbor_tile = get_tile(coord.x, coord.y)
        neighbors.append(neighbor_tile) if neighbor_tile
      end

      @neighbors[generate_index(tile.x, tile.y)] = neighbors
    end
  end

  # Get all neighbor for a Tile of a certain state(s), or all if no states passed
  # @param [Tile] tile
  # @param [Array<Integer>] of_states: Only neighbors with these states, or all if nil
  # @return [Array<Tile>]
  def get_neighbors(tile, of_states = nil)
    neighbors = @neighbors[generate_index(tile.x, tile.y)]
    return unless neighbors

    if of_states
      to_return = []
      neighbors.each do |neighbor|
        to_return.append(neighbor) if neighbor.one_of?(of_states)
      end

      return to_return
    end

    neighbors
  end

  # Update the neighbor states for all Tiles in the grid
  def update_neighbors
    @neighbors.each do
      neighbor_states = [0] * Constants::NUM_TILE_STATES
      get_neighbors.each do |neighbor|
        neighbor_states[neighbor.state] += 1
      end
    end
  end

  # Find perimeter tiles within certain range of center
  # @return [Array<Tile>] center_perimeter_tiles
  def find_central_perimeter_tiles
    center_col = (@cols - 1) / 2
    center_row = (@rows - 1) / 2
    col_range = @cols / 3
    row_range = @rows / 3

    col_min = center_col - col_range
    col_max = center_col + col_range
    row_min = center_row - row_range
    row_max = center_row + row_range

    center_perimeter_tiles = []

    each do |tile|
      next unless tile.x.zero? || tile.x == (@cols - 1) || tile.y.zero? || tile.y == (@rows - 1)

      # Set entire perimeter as padding to not be used later
      tile.become_padding

      if (tile.x > col_min && tile.x < col_max) || (tile.y > row_min && tile.y < row_max)
        center_perimeter_tiles.append(tile)
      end
    end

    center_perimeter_tiles
  end
end
