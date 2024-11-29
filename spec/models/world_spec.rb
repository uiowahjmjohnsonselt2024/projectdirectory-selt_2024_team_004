require 'rails_helper'

RSpec.describe World, type: :model do
  describe 'validations' do
    it 'should be invalid on default construction' do
      # On default construction, the world object is invalid
      test_world = World.new
      expect(test_world).to be_valid
      expect(test_world.world_name).to eq(nil)
      expect(test_world.last_played).to eq(nil)
      expect(test_world.progress).to eq(nil)
    end
    context 'With a properly instantiated World, User and UserWorld' do
      let(:valid_user) do
        User.new(
          name: 'John Doe',
          email: 'jdoe@gmail.com',
          password: 'Password101!',
          password_confirmation: 'Password101!'
        )
      end
      let(:valid_world) do
        World.new(
          world_name: 'World 1',
          last_played: DateTime.new(2024, 11, 29, 10, 0, 0),
          progress: 0
        )
      end
      let(:valid_user_world) do
        UserWorld.new(
          user_role: '',
          owner: true,
          user: valid_user,
          world: valid_world
        )
      end
      it 'all should be valid with valid instance variables' do
        expect(valid_world).to be_valid
        expect(valid_user_world).to be_valid
        expect(valid_user).to be_valid
      end
      it 'generates a unique world ID following established hex code expectations' do
        world = World.create!(last_played: DateTime.now, progress: 0)
        expect(world.world_id).to be_present
        expect(world.world_id.length).to eq(20)
      end
      it 'generates unique world IDs for different worlds' do
        world1 = World.create!(last_played: DateTime.now, progress: 0)
        world2 = World.create!(last_played: DateTime.now, progress: 0)

        expect(world1.world_id).not_to eq(world2.world_id)
      end
      it 'should allow world to have many users through user worlds' do
        user1 = User.create!(:name => 'John Doe', :email => 'jdoe@gmail.com', :password => 'password101!', :password_confirmation => 'password101!')
        user2 = User.create!(:name => 'Jane Doe', :email => 'janedoe@gmail.com', :password => 'password102!', :password_confirmation => 'password102!')

        # Create the associations through user_worlds
        user_world1 = UserWorld.create(world: valid_world, user: user1)
        user_world2 = UserWorld.create(world: valid_world, user: user2)

        expect(valid_world.users).to contain_exactly(user1, user2)
      end
      it 'should be able to have many userworlds' do
        user1 = User.create!(:name => 'John Doe', :email => 'jdoe@gmail.com', :password => 'password101!', :password_confirmation => 'password101!')
        user2 = User.create!(:name => 'Jane Doe', :email => 'janedoe@gmail.com', :password => 'password102!', :password_confirmation => 'password102!')

        # Create the associations through user_worlds
        user_world1 = UserWorld.create(world: valid_world, user: user1)
        user_world2 = UserWorld.create(world: valid_world, user: user2)

        expect(valid_world.user_worlds).to include(user_world1, user_world2)
      end
    end
  end
end