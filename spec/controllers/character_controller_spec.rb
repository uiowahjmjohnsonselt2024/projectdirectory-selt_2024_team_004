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
        allow(valid_character).to receive(:update!).and_raise(StandardError, 'Error saving coordinates')

        post :save_coordinates, params: { id: valid_character.id, x: 20, y: 30 }

        valid_character.reload
        expect(valid_character.x_coord).to eq(10) # Original value remains unchanged
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['error']).to eq('Error saving coordinates')
      end
    end
  end

  describe 'POST #update_shards' do
    context 'when payment is successful' do
      before do
        allow(FakePaymentService).to receive(:charge).and_return(
          { status: 'Success', transaction_id: 'txn_12345' }
        )
      end

      it 'updates shards and returns success' do
        post :update_shards, params: {
          id: valid_character.id,
          shards: 10,
          price: 15.00,
          card_number: '4111111111111111',
          cvv: '123',
          expiration_date: '12/24'
        }

        valid_character.reload
        expect(valid_character.shards).to eq(15)
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['success']).to be true
      end
    end

    context 'when payment fails' do
      before do
        allow(FakePaymentService).to receive(:charge).and_return(
          { status: 'Failure', error: 'Invalid credit card' }
        )
      end

      it 'does not update shards and returns an error' do
        post :update_shards, params: {
          id: valid_character.id,
          shards: 10,
          price: 15.00,
          card_number: '4111111111111111',
          cvv: '123',
          expiration_date: '12/24'
        }

        valid_character.reload
        expect(valid_character.shards).to eq(5) # No update to shards
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
      end
    end
  end

  describe 'PATCH #update' do
    it 'updates the character position and returns success' do
      patch :update, params: { id: valid_character.id, character: { x_coord: 15, y_coord: 25 } }

      valid_character.reload
      expect(valid_character.x_coord).to eq(15)
      expect(valid_character.y_coord).to eq(25)
      expect(response).to have_http_status(:success)
    end

    it 'returns an error if update fails' do
      allow_any_instance_of(Character).to receive(:update).and_return(false)

      patch :update, params: { id: valid_character.id, character: { x_coord: 15, y_coord: 25 } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['success']).to be false
    end
  end
end
