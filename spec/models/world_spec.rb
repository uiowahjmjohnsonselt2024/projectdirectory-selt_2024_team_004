require 'rails_helper'

describe World do
  describe 'Creating a World object' do
    it 'generates a unique world ID following established hex code expectations' do
      world = World.create!(last_played: DateTime.now, progress: 0)
      expect(world.world_id).to be_present
      expect(world.world_id.length).to eq(20)
    end
    it 'generates unique IDs for different worlds' do
      world1 = World.create!(last_played: DateTime.now, progress: 0)
      world2 = World.create!(last_played: DateTime.now, progress: 0)

      expect(world1.id).not_to eq(world2.id)
    end
  end
end