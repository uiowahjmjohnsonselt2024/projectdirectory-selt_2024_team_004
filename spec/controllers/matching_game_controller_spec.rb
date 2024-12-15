require 'spec_helper'
require 'rails_helper'

describe MatchingGameController, type: :controller do
  describe 'GET #index' do
    context 'when user enters the mini-game suite' do
      before do
        allow(User).to receive(:find_by).and_return(double('User'))
        allow(World).to receive(:find_by).and_return(double('World'))
        allow(controller).to receive(:authenticate_user!).and_return(true)
      end

      it 'renders the index view successfully' do
        get :index, params: { user_id: 1, world_id: 2 }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
      end

      it 'assigns shuffled cards to session state' do
        get :index, params: { user_id: 1, world_id: 2 }
        expect(session[:shuffled_cards]).to be_present
        expect(session[:shuffled_cards].length).to eq(10)
      end
    end
  end

  describe 'POST #flip' do
    before do
      session[:shuffled_cards] = (0..4).to_a.concat((0..4).to_a).shuffle
      session[:flipped_cards] = []
      session[:matched_pairs] = []
    end

    context 'when a valid card index is provided' do
      before do
        session[:mini_game_state] = MatchingGame.new
      end

      it 'flips a card and returns waiting status on first flip' do
        post :flip, params: { index: 2 }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'waiting' => true })
      end

      it 'flips two cards and indicates a match or mismatch' do
        post :flip, params: { index: 0 }
        expect(JSON.parse(response.body)).to eq({ 'waiting' => true })
        post :flip, params: { index: 1 }
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json_response).to include('result')
        expect(json_response['result']).to have_key('match')
      end
    end

    context 'when an invalid card index is provided' do
      before do
        session[:mini_game_state] = MatchingGame.new
      end

      it 'returns an error for out-of-range index' do
        post :flip, params: { index: -1 }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['result']).to eq('invalid')
      end

      it 'returns an error for index exceeding card count' do
        post :flip, params: { index: 10 }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid card index')
      end
    end

    context 'when the game is over' do
      it 'indicates the game is over' do
        session[:matched_pairs] = [[0, 1], [2, 3], [4, 5], [6, 7], [8, 9]]
        post :flip, params: { index: 0 }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['game_over']).to eq(true)
      end
    end

    context 'when the game state is missing' do
      it 'returns an error if shuffled_cards is missing' do
        session[:shuffled_cards] = nil
        post :flip, params: { index: 2 }
        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Game state is not initialized')
      end
    end
  end
end
