require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe WorldsController, type: :controller do
  let(:valid_user) do
    User.create(
      name: 'John Doe',
      email: 'jdoe@gmail.com',
      password: 'Password101!',
      password_confirmation: 'Password101!'
    )
  end

  let(:valid_world) do
    World.create(
      world_name: 'World 1',
      last_played: DateTime.new(2024, 11, 29, 10, 0, 0),
      progress: 0
    )
  end

  let!(:valid_user_world) do
    UserWorld.create(
      user_role: 'admin',
      owner: true,
      user: valid_user,
      world: valid_world
    )
  end

  # Simulate login for each test
  before do
    session[:user_id] = valid_user.id
    session[:session_token] = valid_user.session_token
    @current_user = valid_user
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { world_id: valid_world.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #index' do
    context 'when user is logged in' do
      it 'returns a success response and assigns user worlds' do
        get :index
        expect(response).to be_successful
        expect(assigns(:user_worlds)).to eq([valid_user_world])
      end
    end

    context 'when user is not logged in' do
      before do
        session[:user_id] = nil
        session[:session_token] = nil
      end

      it 'redirects to login page with an alert' do
        get :index
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq('Please log in to view your worlds.')
      end
    end
  end
end
