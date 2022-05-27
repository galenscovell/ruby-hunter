require 'gosu'

require './module/constants'
require './module/colors'
require './processing/dungeon'

# The primary window for the application
class Window < Gosu::Window
  def initialize
    super(Constants::SCREEN_WIDTH, Constants::SCREEN_HEIGHT, false)
    self.caption = 'Probable Journey'
    self.borderless = false

    @dungeon = Dungeon.new(
      pixel_width: Constants::SCREEN_WIDTH,
      pixel_height: Constants::SCREEN_HEIGHT,
      target_rooms: 4,
      min_room_width: 4,
      max_room_width: 6,
      min_room_height: 4,
      max_room_height: 6,
      min_hall_length: 4,
      max_hall_length: 6
    )
    @dungeon.set_neighbors
    @dungeon.build_initial_hall
    @constructing = true
  end

  def update
    if @constructing
      return if @dungeon.work_remains

      @constructing = false
    end
  end

  def draw
    (0...@dungeon.cols).each do |x|
      (0...@dungeon.rows).each do |y|
        tile = @dungeon.grid[x][y]

        if tile.empty?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::EMPTY)
        elsif tile.floor?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::FLOOR)
        elsif tile.wall?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::WALL)
        elsif tile.corner?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::CORNER)
        elsif tile.hall?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::HALL)
        elsif tile.padding?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::PADDING)
        elsif tile.water?
          Gosu::draw_rect(tile.pixel_x, tile.pixel_y, Constants::TILE_SIZE, Constants::TILE_SIZE, Colors::WATER)
        end
      end
    end
  end
end
