require 'gosu'

require './model/vector2'
require './module/colors'
require './module/constants'
require './processing/dungeon'
require './processing/pathfinding'

# The primary window for the application
class Window < Gosu::Window
  def initialize
    super(Constants::SCREEN_WIDTH, Constants::SCREEN_HEIGHT, false)
    self.caption = 'Probable Journey'
    self.borderless = false
    self.update_interval = 16.6

    @font = Gosu::Font.new(self, 'Source Code Pro', 21)
    @start_clicked = nil
    @end_clicked = nil

    @dungeon = Dungeon.new(
      pixel_width: Constants::SCREEN_WIDTH,
      pixel_height: Constants::SCREEN_HEIGHT,
      target_rooms: 14,
      min_room_width: 3,
      max_room_width: 5,
      min_room_height: 3,
      max_room_height: 5,
      min_hall_length: 2,
      max_hall_length: 6
    )

    @pathfinding = Pathfinding.new(@dungeon.grid)
    @constructing = true
  end

  def update
    if @constructing
      return if @dungeon.work_remains

      @constructing = false
    end

    if @pathfinding.working
      if @pathfinding.step
        path = @pathfinding.trace_path
        path.each do |tile|
          tile.become_path
        end
      end
    end
  end

  def draw
    @dungeon.draw

    @font.draw_text("#{mouse_x}, #{mouse_y}", 8, 8, 0)
    if @start_clicked
      @font.draw_text("Start [#{@start_clicked.to_str}]", 8, 32, 0)
    else
      @font.draw_text("Start [-, -]", 8, 32, 0)
    end

    if @end_clicked
      @font.draw_text("End   [#{@end_clicked.to_str}]", 8, 48, 0)
    else
      @font.draw_text("End   [-, -]", 8, 48, 0)
    end
  end

  def button_down(id)
    if id == Gosu::MsLeft
      pos_x = (mouse_x / (Constants::TILE_SIZE + Constants::MARGIN)).to_i
      pos_y = (mouse_y / (Constants::TILE_SIZE + Constants::MARGIN)).to_i

      clicked_tile = @dungeon.grid.get_tile(pos_x.to_i, pos_y.to_i)
      if clicked_tile&.floor? || clicked_tile&.hall?
        if !@start_clicked
          @start_clicked = clicked_tile
          clicked_tile.become_start_point
        elsif !@end_clicked
          @end_clicked = clicked_tile
          clicked_tile.become_end_point
          @pathfinding.begin_scan(@start_clicked, @end_clicked)
        end
      end
    elsif id == Gosu::MsRight
      @pathfinding.clear
      @start_clicked = nil
      @end_clicked = nil
    end
  end
end
