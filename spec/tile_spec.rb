require 'rspec'

require './model/tile'
require './module/constants'

describe Tile do
  let(:tile) { Tile.new(2, 5) }

  it 'can be printed' do
    expect(tile.to_str).to eq('2, 5')
  end

  context 'When comparing' do
    it 'has proper equality' do
      expect(tile == Tile.new(2, 5)).to eq(true)
    end

    it 'has proper inequality' do
      expect(tile == Tile.new(2, 4)).to eq(false)
    end
  end

  context 'When creating' do
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

  context 'When modifying' do
    it 'updates state correctly' do
      expect(tile.empty?).to eq(true)
      tile.become_wall
      expect(tile.empty?).to eq(false)
      expect(tile.wall?).to eq(true)
      tile.become_floor
      expect(tile.wall?).to eq(false)
      expect(tile.floor?).to eq(true)
    end

    it 'can become part of room' do
      expect(tile.room_id).to eq(-1)
      tile.set_room(1)
      expect(tile.room_id).to eq(1)
      tile.remove_room
      expect(tile.room_id).to eq(-1)
    end

    it 'can become part of hall' do
      expect(tile.hall_id).to eq(-1)
      tile.set_hall(1)
      expect(tile.hall_id).to eq(1)
      tile.remove_hall
      expect(tile.hall_id).to eq(-1)
    end
  end
end
