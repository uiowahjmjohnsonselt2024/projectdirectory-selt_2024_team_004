class MatchingGameController < ApplicationController
  def index
    # Create a new minigame instance each time user is directed to the view
    # Use session to store minigame data during each game
    @minigame = MatchingGame.new
    session[:minigame] = @minigame
  end
end