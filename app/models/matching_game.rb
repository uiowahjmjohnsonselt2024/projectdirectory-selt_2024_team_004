class MatchingGame
  attr_reader :cards_idx, :flipped_cards, :matches_idx
  def initialize
    @cards_idx = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4].shuffle  # index of the image that will show when card flips
    @flipped_cards = []   # stores the indicies of the cards the user has flipped, can only flip 2
    @matches_idx = []     # stores what images have been successfully matched by the user
  end

  def flip_card(idx)
    # First check if the card is already flipped or matched
    return nil if @flipped_cards.include?(idx) || @matches_idx.flatten.include?(idx)

    # If not, add the index to flipped_cards
    @flipped_cards << idx

    # If user has flipped 2 cards, check if they match, otherwise do nothing
    if @flipped_cards.length == 2
      # Check if the cards are a match
      if @cards_idx[@flipped_cards[0]] == @cards_idx[@flipped_cards[1]]
        # Add that index to the array of matches the user has made
        @matches_idx << [@flipped_cards[0], @flipped_cards[1]]

        # Reset flipped_cards
        @flipped_cards = []
      else
        # Cards should be flipped back over, resetting flipped_cards to an empty array
        @flipped_cards = []
      end
    end
  end

  def game_over?
    @matches_idx.length == @cards_idx.length / 2
  end

  # Helper function for RSpec tests
  def get_matches
    matched_pairs = []

    # Go through each card index
    @cards_idx.each_with_index do |card_idx1, index1|
      # Take a slice of the array from index1 + 1 so as to not include the index the first each block is on
      # This prevents duplicate matches from showing up in matched_pairs
      @cards_idx[(index1 + 1)..-1].each_with_index do |card_idx2, index2|
        if card_idx1 == card_idx2
          matched_pairs << [index1, index1 + index2 + 1]
        end
      end
    end

    # Return the indicies of the matching cards
    matched_pairs
  end
end
