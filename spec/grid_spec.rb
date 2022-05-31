require 'rspec'

require './model/grid'
require './model/tile'
require './module/constants'

describe Grid do
  pixel_width = 360
  pixel_height = 120
  rows = pixel_height / (Constants::TILE_SIZE + Constants::MARGIN)
  cols = pixel_width / (Constants::TILE_SIZE + Constants::MARGIN)

  let(:grid) { Grid.new(pixel_width, pixel_height) }

  context 'After creation' do
    it 'has correct size' do
      expect(grid.count).to eq(rows * cols)
    end

    it 'can generate indices' do
      idx = grid.generate_index(0, 0)
      expect(idx).to eq(0)

      idx = grid.generate_index(1, 0)
      expect(idx).to eq(1)

      idx = grid.generate_index(12, 4)
      expect(idx).to eq((4 * cols) + 12)
    end

    it 'can pull tiles' do
      tile = grid.get_tile(0, 0)
      expect(tile).to_not be_nil

      tile = grid.get_tile(12, 4)
      expect(tile).to_not be_nil

      tile = grid.get_tile(12, 40)
      expect(tile).to be_nil
    end

    it 'has tile neighbors set' do
      tile = grid.get_tile(0, 0)
      neighbors = grid.get_neighbors(tile)
      expect(neighbors.count).to eq(2)

      tile = grid.get_tile(12, 0)
      neighbors = grid.get_neighbors(tile)
      expect(neighbors.count).to eq(3)

      tile = grid.get_tile(12, 6)
      neighbors = grid.get_neighbors(tile)
      expect(neighbors.count).to eq(4)
    end
  end
end