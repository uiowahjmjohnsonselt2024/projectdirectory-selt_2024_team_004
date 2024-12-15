require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe CharactersController, type: :controller do
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
      character_id: '001',
      image_code: '1_1_1.png',
      x_coord: 10,
      y_coord: 10,
      shards: 5,
      world_id: valid_world.id,
      user_id: valid_user.id
    )
  end

  before do
    session[:user_id] = valid_user.id
    session[:session_token] = valid_user.session_token
    @current_user = valid_user

    allow(Character).to receive(:find).and_return(valid_character)
  end

  describe 'POST #save_coordinates' do
    context 'when update is successful' do
      it 'updates the character coordinates and returns a success message' do
        post :save_coordinates, params: { id: valid_character.character_id, x: 20, y: 30 }

        valid_character.reload
        expect(valid_character.x_coord).to eq(20)
        expect(valid_character.y_coord).to eq(30)
        expect(response).to have_http_status(:success) # Ensure no error occurred
        expect(assigns(:character)).to eq(valid_character)
      end
    end

    context 'when update fails' do
      it 'does not update the character coordinates and prints an error message' do
        allow(valid_character).to receive(:update).and_return(false) # Simulate update failure
        post :save_coordinates, params: { id: 1, x: 20, y: 30 }

        expect(valid_character.x_coord).to eq(10) # Original value remains unchanged
        expect(response.body).to include('Error updating coordinates')
      end
    end

    context 'when character is not found' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        allow(Character).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect {
          post :save_coordinates, params: { id: 9999, x: 20, y: 30 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
