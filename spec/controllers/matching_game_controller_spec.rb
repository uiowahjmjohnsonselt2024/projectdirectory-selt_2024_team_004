require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe MatchingGameController, type: :controller do
  describe "GET #index" do
    context 'when user has entered the mini-game suite' do
      it 'renders the index view successfully' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
      end

      it 'initializes a new mini game and sets session state' do
        get :index
        expect(assigns(:mini_game)).to be_a(MatchingGame)
        expect(session[:mini_game_state]).not_to be_nil
      end

      it 'assigns shuffled cards to @shuffled_cards' do
        get :index
        expect(assigns(:shuffled_cards)).to be_present
        expect(assigns(:shuffled_cards)).to be_an(Array)
      end

      it 'loads card images into @images' do
        get :index
        expect(assigns(:images)).to match_array(
                                      ["card_image1.png", "card_image2.png", "card_image3.png", "card_image4.png", "card_image5.png"]
                                    )
      end
    end

    # Test for flip action

    describe "POST #flip" do
      context 'when mini game state is valid' do
        before do
          session[:mini_game_state] = MatchingGame.new.state
        end

        it 'flips a card and returns the correct response' do
          post :flip, params: { index: 2 }
          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(json_response['card']['index']).to eq(2)
          expect(json_response['card']['image']).to eq('card_image3.png')
          expect(json_response['result']).not_to be_nil
          expect(json_response['game_status']).not_to be_nil
        end

        it 'updates session state after flipping a card' do
          initial_game = MatchingGame.new
          session[:mini_game_state] = initial_game.state
          post :flip, params: { index: 2 }

          expect(session[:mini_game_state]).not_to eq(initial_game.state)
        end
      end

      context 'when an invalid card index is provided' do
        before do
          session[:mini_game_state] = MatchingGame.new.state
        end

        it 'handles invalid card index gracefully' do
          post :flip, params: { index: -1 }
          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok) # or another expected status
          expect(json_response['result']).to eq('invalid') # Depending on your game logic
        end
      end

      context 'when mini game is not initialized' do
        before do
          session[:mini_game_state] = nil
        end

        it 'returns an error when mini game is not properly instantiated' do
          post :flip, params: { index: 2 }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['error']).to eq('Failed to generate and set new mini game.')
        end
      end

      context 'when game is over' do
        before do
          game = MatchingGame.new
          allow(game).to receive(:game_over?).and_return(true)
          session[:mini_game_state] = game.state
        end

        it 'indicates when the game is over' do
          post :flip, params: { index: 2 }
          json_response = JSON.parse(response.body)

          expect(json_response['game_status']).to eq(true)
        end
      end
    end
  end
end
