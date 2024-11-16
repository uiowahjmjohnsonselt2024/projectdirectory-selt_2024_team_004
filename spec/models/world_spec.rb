require 'rails_helper'

describe World, type: :controller do
  describe 'Creating a World object' do
    context 'With a user that already exists' do
      let(:valid_world) do
        world = World.new
        world.name = 'World 1'
      end
      before do
        valid_world.save
      end
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
      it 'should be able to have many worlds through user worlds' do
        user1 = User.create
        user2 = User.create

        # Create the associations through user_worlds
        user_world1 = UserWorld.create(user: valid_world, world: user1)
        user_world2 = UserWorld.create(user: valid_world, world: user2)

        expect(valid_user.worlds).to include(user1, user2)
      end
      it 'should be able to have many userworlds' do
        world1 = World.create

        # Create the associations through user_worlds
        user_world1 = UserWorld.create(user: valid_user, world: world1)
        user_world2 = UserWorld.create(user: valid_user, world: world1)

        expect(valid_world.user_worlds).to include(user_world1, user_world2)
      end
    end
  end
end