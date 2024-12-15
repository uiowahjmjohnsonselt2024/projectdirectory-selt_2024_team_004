require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe SquaresController, type: :controller do
  let(:valid_user) do
    User.create!(
      name: 'John Doe',
      email: 'jdoe@gmail.com',
      password: 'Password101!',
      password_confirmation: 'Password101!'
    )
  end

  let(:valid_world) do
    World.create!(
      world_name: 'World 1',
      last_played: DateTime.new(2024, 11, 29, 10, 0, 0),
      progress: 0
    )
  end

  let(:valid_character) do
    Character.create!(
      x_coord: 0,
      y_coord: 0,
      shards: 5,
      user_id: valid_user.id,
      world_id: valid_world.id,
      character_id: SecureRandom.uuid,
      image_code: '1_1_1.png'
    )
  end

  let!(:square1) do
    Square.create!(
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
    Square.create!(
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
    allow(controller).to receive(:current_user).and_return(valid_user)
    session[:user_id] = valid_user.id
    session[:world_id] = valid_world.id
    session[:character_id] = valid_character.id
  end

  describe 'GET #landing' do
    context 'when world_id is provided' do
      it 'assigns @world_id and @squares in correct order' do
        get :landing, params: { world_id: valid_world.id, user_id: valid_user.id }

        expect(assigns(:world_id)).to eq(valid_world.id)
        expect(assigns(:squares)).to eq([square2, square1])
        expect(response).to have_http_status(:success)
      end

      it 'assigns @character with x_coord and y_coord defaults if no character exists' do
        Character.where(user_id: valid_user.id, world_id: valid_world.id).delete_all # Ensure no character exists

        # Verify a new character is created
        expect do
                  get :landing, params: { world_id: valid_world.id, user_id: valid_user.id }
                end.to change { Character.count }.by(1)
        character = assigns(:character)
        expect(character).not_to be_nil
        expect(character.x_coord).to eq(0) # Default x_coord
        expect(character.y_coord).to eq(0) # Default y_coord
      end

      it 'ensures @character is saved when coordinates are updated' do
        valid_character.update(x_coord: 10) # Simulate updated coordinates
        allow_any_instance_of(Character).to receive(:changed?).and_return(true)
        expect_any_instance_of(Character).to receive(:save!)

        get :landing, params: { world_id: valid_world.id, user_id: valid_user.id }
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

    context 'when minigame victory handling is invoked' do
      it 'updates the square and character correctly for a minigame victory' do
        # Ensure valid character is assigned and initial shards are set
        valid_character.update!(shards: 5)

        get :landing, params: { world_id: valid_world.id, square_id: square1.square_id, game_result: 'true' }

        character = assigns(:character)
        expect(character.shards).to eq(6) # Verify shards are incremented by 1
        square = assigns(:squares).find { |sq| sq.square_id == square1.square_id }
        expect(square.state).to eq('active') # Verify square state is updated to 'active'
      end

      it 'logs an error if square is not found during minigame victory handling' do
        allow(Square).to receive(:find_by).with(square_id: 'sq_invalid').and_return(nil)
        expect(Rails.logger).to receive(:error).with(/No square found/)

        get :landing, params: { world_id: valid_world.id, square_id: 'sq_invalid', game_result: 'true' }
      end
    end
  end
end
