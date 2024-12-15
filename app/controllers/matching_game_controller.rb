class MatchingGameController < ApplicationController
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: [:flip]

  def index
    @user = User.find_by(id: params[:user_id])
    return redirect_to root_path, alert: 'Invalid user' unless @user

    @world = World.find_by(id: params[:world_id])
    return redirect_to worlds_path, alert: 'Invalid world' unless @world

    @square_id = params[:square_id]

    # Initialize game state
    session[:shuffled_cards] = (0..4).to_a.concat((0..4).to_a).shuffle
    session[:flipped_cards] = []
    session[:matched_pairs] = []

    @shuffled_cards = session[:shuffled_cards]
  end

  def flip
    card_idx = params[:index].to_i
    if card_idx < 0 || card_idx >= session[:shuffled_cards].size
      render json: { error: 'Invalid index' }, status: :unprocessable_entity
      return
    end

    # Get current game state from session
    flipped_cards = session[:flipped_cards]
    matched_pairs = session[:matched_pairs] || []
    shuffled_cards = session[:shuffled_cards]

    render json: { status: 'invalid', reason: 'already flipped' } and return if flipped_cards.include?(card_idx)
    render json: { status: 'invalid', reason: 'already matched' } and return if matched_pairs.flatten.include?(card_idx)

    # Add current card to flipped cards
    flipped_cards << card_idx

    if flipped_cards.length == 2
      first_card_idx, second_card_idx = flipped_cards

      # Check if cards match
      is_match = shuffled_cards[first_card_idx] == shuffled_cards[second_card_idx]

      if is_match
        matched_pairs << [first_card_idx, second_card_idx]
        session[:matched_pairs] = matched_pairs
      end

      # Clear flipped cards for next turn
      session[:flipped_cards] = []

      render json: {
        first_card_index: first_card_idx,
        second_card_index: second_card_idx,
        result: { match: is_match },
        game_over: matched_pairs.length == 5
      } and return
    end

    # First card - store in session and wait for second card
    session[:flipped_cards] = flipped_cards
    render json: { waiting: true } and return
  rescue => e
    Rails.logger.error "Flip error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: e.message }, status: 500
  end
end