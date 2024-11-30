class MatchingGameController < ApplicationController
  before_action :load_images, only: [:index, :flip]
  def index
    # Create a new minigame instance each time user is directed to the view
    # Use session to store minigame data during each game
    @mini_game = MatchingGame.new
    session[:mini_game_state] = @mini_game.state
    @shuffled_cards = @mini_game.cards_idx
    puts @shuffled_cards
  end
  def load_images
    # Load images 1-5 from the app/assets/images directory
    # Images are named card_image1.png, card_image2.png, etc.
    @images = (1..5).map {|i| "card_image#{i}.png"}
  end

  def flip
    # Get the current state of the minigame
    @mini_game = MatchingGame.new(session[:mini_game_state])
    puts @mini_game.inspect

    # Check for the case that minigame was not properly instantiated
    return render json: {error: "Failed to generate and set new mini game."}, status: :unprocessable_entity if @mini_game.nil?

    # Otherwise, call model's flip_card method to handle flipping of a card
    # Get the index of the flipped card from the parameters and convert to an integer
    card_idx = params[:index].to_i

    # Flip the card and get the resulting state of the game
    result = @mini_game.flip_card(card_idx)

    # Update game session
    session[:mini_game_state] = @mini_game.state

    # Check if the user has matched all cards and the game is over
    game_status = @mini_game.game_over?

    # Build the response JSON with necessary information
    response = {
      card: {
        index: card_idx,
        image: @images[card_idx]
      },
      result: result,
      game_status: game_status
    }

    # Return the JSON response
    render json: response
  end
end