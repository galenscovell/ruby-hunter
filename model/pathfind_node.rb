require './model/tile'

# Defines a node to be used for Pathfinding operations
class PathfindNode
  attr_accessor :tile, :parent, :cost_from_start, :total_cost

  # @param [Tile] tile: Tile associated with this node
  def initialize(tile)
    @tile = tile
    @cost_from_start = 0
    @total_cost = 0
    @parent = nil
  end
end
