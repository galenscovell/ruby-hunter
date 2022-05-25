require 'rspec'

require './model/tile'
require './module/constants'

describe Tile do
  let(:tile) { Tile.new(2, 5) }

  context 'When creating Tile object' do
    it 'has coordinates' do
      expect(tile.x).to eq(2)
      expect(tile.y).to eq(5)
    end

    it 'does not begin in a room' do
      expect(tile.room_id).to eq(-1)
    end

    it 'does not begin in a hall' do
      expect(tile.hall_id).to eq(-1)
    end

    it 'starts in empty state' do
      expect(tile.empty?).to eq(true)
    end
  end

  context 'When modifying Tile details' do
    it 'updates state correctly' do
      expect(tile.empty?).to eq(true)
      tile.become_wall
      expect(tile.empty?).to eq(false)
      expect(tile.wall?).to eq(true)
      tile.become_floor
      expect(tile.wall?).to eq(false)
      expect(tile.floor?).to eq(true)
    end
  end
end
