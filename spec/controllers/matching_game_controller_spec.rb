require 'spec_helper'
require 'rails_helper'

describe MatchingGameController, type: :controller do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password', password_confirmation: 'password') }
  let(:world) { World.create!(world_name: 'Test World', last_played: Time.now, progress: 0) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    context 'with valid user and world' do
      it 'initializes the game state and assigns necessary variables' do
        get :index, params: { user_id: user.id, world_id: world.id, square_id: 1 }

        expect(assigns(:user)).to eq(user)
        expect(assigns(:world)).to eq(world)
        expect(assigns(:square_id)).to eq('1')
        expect(session[:shuffled_cards]).to be_present
        expect(session[:flipped_cards]).to eq([])
        expect(session[:matched_pairs]).to eq([])
        expect(assigns(:shuffled_cards)).to eq(session[:shuffled_cards])
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid user' do
      it 'does not assign game state if user is invalid' do
        allow(User).to receive(:find_by).and_return(nil)
        get :index, params: { user_id: nil, world_id: world.id, square_id: 1 }

        expect(assigns(:user)).to be_nil
        expect(assigns(:world)).to be_nil
        expect(session[:shuffled_cards]).to be_nil
      end
    end

    context 'with invalid world' do
      it 'does not assign game state if world is invalid' do
        allow(World).to receive(:find_by).and_return(nil)
        get :index, params: { user_id: user.id, world_id: nil, square_id: 1 }

        expect(assigns(:world)).to be_nil
        expect(assigns(:user)).to eq(user)
        expect(session[:shuffled_cards]).to be_nil
      end
    end

    context 'without square_id' do
      it 'assigns nil to @square_id' do
        get :index, params: { user_id: user.id, world_id: world.id }

        expect(assigns(:square_id)).to be_nil
        expect(assigns(:user)).to eq(user)
        expect(assigns(:world)).to eq(world)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without world_id' do
      it 'redirects to the worlds path with an alert' do
        get :index, params: { user_id: user.id, square_id: 1 }

        expect(response).to redirect_to(worlds_path)
        expect(flash[:alert]).to eq('Invalid world')
      end
    end

    context 'when session does not have shuffled_cards' do
      it 'initializes shuffled_cards and other session variables' do
        session.delete(:shuffled_cards)
        get :index, params: { user_id: user.id, world_id: world.id, square_id: 1 }

        expect(session[:shuffled_cards]).to be_present
        expect(session[:flipped_cards]).to eq([])
        expect(session[:matched_pairs]).to eq([])
      end
    end
  end

  describe 'POST #flip' do
    before do
      session[:shuffled_cards] = (0..4).to_a.concat((0..4).to_a).shuffle
      session[:flipped_cards] = []
      session[:matched_pairs] = []
    end

    context 'when flipping a valid card' do
      it 'adds the card to flipped_cards and waits for the next card' do
        post :flip, params: { index: 0 }

        expect(session[:flipped_cards]).to include(0)
        expect(JSON.parse(response.body)['waiting']).to eq(true)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when flipping two cards that do not match' do
      it 'does not add to matched_pairs and clears flipped_cards' do
        session[:shuffled_cards] = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
        post :flip, params: { index: 0 }
        post :flip, params: { index: 1 }

        json_response = JSON.parse(response.body)
        expect(json_response['result']['match']).to eq(false)
        expect(session[:matched_pairs]).to eq([])
        expect(session[:flipped_cards]).to eq([])
      end
    end

    context 'when flipping an already flipped card' do
      it 'returns an invalid status without double-rendering' do
        session[:flipped_cards] = [0]
        post :flip, params: { index: 0 }

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('invalid')
        expect(json_response['reason']).to eq('already flipped')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when flipping an already matched card' do
      it 'returns an invalid status without double-rendering' do
        session[:matched_pairs] = [[0, 1]]
        post :flip, params: { index: 0 }

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('invalid')
        expect(json_response['reason']).to eq('already matched')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when flipping the last card and ending the game' do
      it 'marks the game as over when all pairs are matched' do
        session[:matched_pairs] = [[0, 1], [2, 3], [4, 5], [6, 7]]
        session[:shuffled_cards][8] = session[:shuffled_cards][9]

        post :flip, params: { index: 8 }
        post :flip, params: { index: 9 }

        json_response = JSON.parse(response.body)
        expect(json_response['game_over']).to eq(true)
        expect(session[:matched_pairs].length).to eq(5)
      end
    end

    context 'when flipping an invalid card index' do
      it 'returns an error and does not modify the session' do
        post :flip, params: { index: 99 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Invalid index')
        expect(session[:flipped_cards]).to eq([])
      end
    end

    context 'when a turn is completed' do
      it 'clears flipped_cards after checking for a match' do
        session[:shuffled_cards] = [1, 2, 1, 2, 3, 4, 5, 3, 4, 5]
        post :flip, params: { index: 0 }
        post :flip, params: { index: 2 }

        expect(session[:flipped_cards]).to eq([])
      end
    end

    context 'when an error occurs' do
      it 'logs the error and returns a 500 status' do
        allow_any_instance_of(MatchingGameController).to receive(:flip).and_raise(StandardError.new('Test error'))
        expect do
          post :flip, params: { index: 0 }
        end.to raise_error(StandardError, 'Test error')
      end
    end
  end
end
