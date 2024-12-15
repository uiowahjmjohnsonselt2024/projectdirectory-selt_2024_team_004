require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe SquaresController, type: :controller do
  let(:valid_character) { double('Character', x_coord: 0, y_coord: 0) }
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

  let!(:square1) do
    Square.create(
      square_id: 'sq_001',
      world_name: valid_world.world_name,
      world_id: valid_world.id,
      x: 1,
      y: 2,
      weather: 'sunny',
      treasure: false
    )
  end

  let!(:square2) do
    Square.create(
      square_id: 'sq_002',
      world_name: valid_world.world_name,
      world_id: valid_world.id,
      x: 0,
      y: 1,
      weather: 'rainy',
      treasure: true
    )
  end

  before do
    allow(StoreService).to receive(:fetch_prices).and_return({ 'item1' => 10, 'item2' => 20 })
    allow(Character).to receive(:find_by).with(world_id: valid_world.id).and_return(valid_character)
    allow(controller).to receive(:current_user).and_return(valid_user)
    session[:user_id] = valid_user.id
    session[:world_id] = valid_world.id
  end

  describe 'GET #landing' do
    context 'when world_id is provided' do
      it 'assigns @world_id and @squares in correct order' do
        get :landing, params: { world_id: valid_world.id, user_id: valid_user.id }

        expect(assigns(:world_id)).to eq(valid_world.id.to_s)
        expect(assigns(:squares)).to eq([square2, square1])
        expect(response).to have_http_status(:success)
      end

      it 'assigns @character with x_coord and y_coord defaults' do
        allow(Character).to receive(:find_by).with(world_id: valid_world.id).and_return(nil)

        get :landing, params: { world_id: valid_world.id }
        character = assigns(:character)

        expect(character).not_to be_nil
        expect(character.x_coord).to eq(0)
        expect(character.y_coord).to eq(0)
      end
    end

    context 'when world_id is not provided' do
      it 'redirects to worlds_path with a flash alert' do
        get :landing, params: { user_id: valid_user.id }

        expect(flash[:alert]).to eq('No world selected')
        expect(response).to redirect_to(worlds_path)
      end
    end

    context 'interaction with store method' do
      it 'assigns user, currency, and prices from the store method' do
        get :landing, params: { world_id: valid_world.id, user_id: valid_user.id }

        expect(assigns(:user)).to eq(valid_user)
        expect(assigns(:currency)).to eq('USD')
        expect(assigns(:prices)).to eq({ 'item1' => 10, 'item2' => 20 })
      end
    end
  end
end
