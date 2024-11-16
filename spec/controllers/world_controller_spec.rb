require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe WorldsController do
  let(:user) do
    User.create!(email: 'testuser@example.com', password: 'password', password_confirmation: 'password')
  end

  before do
    post login_path, params: { email: user.email, password: 'password' }
  end

  describe 'Creating a new world' do
    it 'should create a new world with my selected character options' do
      fake_role = {
        gender: 1,
        preload: 1,
        role: 1
      }
      post :create, params: fake_role

      user_world = UserWorld.last
      expect(user_world.user).to eq(user)
      expect(user_world.world).to eq(World.last)

      expect(flash[:notice]).to eq('World created successfully!')

      expect(response).to redirect_to(worlds_path)
    end
  end
end