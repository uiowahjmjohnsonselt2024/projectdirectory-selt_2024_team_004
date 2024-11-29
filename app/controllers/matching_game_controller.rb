class MatchingGameController < ApplicationController
  def index
    # Load the images by calling the helper function
    load_images

    # Create a new minigame instance each time user is directed to the view
    # Use session to store minigame data during each game
    @mini_game = MatchingGame.new
    session[:mini_game] = @mini_game
  end
  def load_images
    # TMP PLACEHOLDER
    @images = ["image1", "image2", "image3", "image4", "image5"]
  end

  def flip
    # Get the current state of the minigame
    @mini_game = session[:mini_game]

    # Check for the case that minigame was not properly instantiated
    return render json: {error: "Failed to generate and set new mini game."}, status: :unprocessable_entity if @mini_game.nil?

    # Otherwise, call model's flip_card method to handle flipping of a card
    # Get the index of the flipped card from the parameters and convert to an integer
    card_idx = params[:index].to_i

    # Check if the user has matched all cards and the game is over
    game_status = @mini_game.game_over?

    # Update game session
    session[:mini_game] = @mini_game

    # Respond with a JSON object
    render json: {card: card}
  end
end