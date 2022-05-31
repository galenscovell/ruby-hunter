require './model/pathfind_node'
require './model/tile'

# Defines logic for pathfinding between Tiles
class Pathfinding
  attr_reader :working

  def initialize(tile_grid)
    @tile_grid = tile_grid
    @open = []
    @closed = []
    @start = nil
    @end = nil
    @working = false
    @path_check_states = [TileType::FLOOR, TileType::HALL, TileType::END_POINT]
    @clear_check_states = [TileType::EXPLORED, TileType::START_POINT, TileType::END_POINT, TileType::PATH]
  end

  # Clear any previous scans
  def clear
    @open.clear
    @closed.clear
    @tile_grid.each do |tile|
      tile.become_floor if tile.one_of?(@clear_check_states)
    end
  end

  # Initialize a pathfinding scan with given start and end tiles
  def begin_scan(start_tile, end_tile)
    @start = PathfindNode.new(start_tile)
    @end = PathfindNode.new(end_tile)
    @start.cost_from_start = 0
    @start.total_cost = 0
    @open.append(@start)
    @working = true
  end

  # Perform one step on current pathfinding goal
  # @return [Boolean] True if goal has been reached
  def step
    if @open.empty?
      @working = false
      return false
    end

    curr = best_option
    if curr.tile == @end.tile
      @end = curr
      @working = false
      return true
    end

    @open.delete(curr)
    @closed.append(curr)
    @tile_grid.get_neighbors(curr.tile).each do |neighbor|
      next unless neighbor&.one_of?(@path_check_states)

      neighbor_node = PathfindNode.new(neighbor)

      next if in_list(neighbor, @closed)

      neighbor_node.total_cost = curr.cost_from_start + heuristic(neighbor_node)

      next if in_list(neighbor, @open)

      neighbor.become_explored unless neighbor.end?
      neighbor_node.parent = curr
      @open.append(neighbor_node)
    end

    false
  end

  # Check if either the open or closed options contains a node with the given Tile
  # @return [Boolean]
  def in_list(tile, node_list)
    node_list.each do |node|
      return true if node.tile == tile
    end

    false
  end

  # Find the next best option among the available nodes in open options
  # @return [PathfindNode]
  def best_option
    min_cost = Float::INFINITY
    best = nil

    @open.each do |node|
      total_cost = node.cost_from_start + heuristic(node)
      if min_cost > total_cost
        min_cost = total_cost
        best = node
      end
    end

    best
  end

  # Calculate Euclidean distance heuristic
  # @return [Float]
  def heuristic(start_node)
    dx = start_node.tile.x - @end.tile.x
    dy = start_node.tile.y - @end.tile.y
    Math.sqrt(dx * dx + dy * dy)
  end

  # Returns ordered stack of points along movement path
  # @return [Array<Tile>]
  def trace_path
    path = []
    node = @end
    while node.parent
      curr = node.tile
      path.append(curr) unless curr.end?
      node = node.parent
    end

    path
  end
end
