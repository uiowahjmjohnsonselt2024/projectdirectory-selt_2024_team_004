class MatchingGame
  def initialize
    @images = ['image1', 'image2', 'image3', 'image4', 'image5']  # placeholder for now
    @cards_idx = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4].shuffle  # index of the image that will show when card flips
    @flipped_cards = []   # stores the indicies of the cards the user has flipped, can only flip 2
    @matches_idx = []     # stores what images have been successfully matched by the user
  end

  def flip_card(idx)
    # First check if the card is already flipped or matched
    return nil if @flipped_cards.include?(idx) || @matches.include?(idx)

    # If not, add the index to flipped_cards
    @flipped_cards << idx

    # If user has flipped 2 cards, check if they match, otherwise do nothing
    if @flipped_cards.length == 2
      # Check if the cards are a match
      if @flipped_cards[0] == @flipped_cards[1]
        # Add that index to the array of matches the user has made
        @matches_idx << idx
      else
        # Cards should be flipped back over, resetting flipped_cards to an empty array
        @flipped_cards = []
      end
    end
  end

  def game_over?
    @matches_idx.length == @images.length
  end
end