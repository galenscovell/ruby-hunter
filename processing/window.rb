require 'gosu'

require './module/constants'
require './module/colors'
require './processing/dungeon'

# The primary window for the application
class Window < Gosu::Window
  def initialize
    super(Constants::SCREEN_WIDTH, Constants::SCREEN_HEIGHT, false)
    self.caption = 'Ruby Miner'
    self.borderless = false
    @dungeon = Dungeon.new(Constants::SCREEN_WIDTH, Constants::SCREEN_HEIGHT, 4, 4, 6, 4, 6, 4, 6)
  end

  def update

  end

  def draw
    @dungeon.render
  end
end
