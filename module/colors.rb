require 'gosu'

module Colors
  EMPTY = Gosu::Color.rgba(52, 73, 94, 255)
  FLOOR = [
    Gosu::Color.rgba(247, 241, 227, 255),
    Gosu::Color.rgba(247, 241, 227, 250),
    Gosu::Color.rgba(247, 241, 227, 245)
  ].freeze
  WALL = [
    Gosu::Color.rgba(132, 129, 122, 255),
    Gosu::Color.rgba(132, 129, 122, 240),
    Gosu::Color.rgba(132, 129, 122, 225)
  ].freeze

  PERIMETER = Gosu::Color.rgba(44, 62, 80, 255)
  CORNER = Gosu::Color.rgba(64, 64, 122, 255)
  HALL = Gosu::Color.rgba(247, 241, 227, 255)
  PADDING = Gosu::Color.rgba(64, 64, 122, 255)
  WATER = Gosu::Color.rgba(52, 172, 224, 255)

  ENDPOINT = Gosu::Color.rgba(255, 121, 63, 255)
  PATH = Gosu::Color.rgba(255, 177, 66, 255)
  EXPLORE_START = Gosu::Color.rgba(236, 240, 241, 255)
  EXPLORE_END = Gosu::Color.rgba(52, 172, 224, 255)

  TEXT = Gosu::Color.rgba(255, 82, 82, 255)
end
