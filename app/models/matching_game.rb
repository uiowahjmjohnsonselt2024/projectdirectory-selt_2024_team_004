class MatchingGame
  attr_reader :state, :cards_idx

  def initialize(state = nil)
    if state
      @state = state
      @cards_idx = state[:cards_idx]
    else
      # Initialize a new game
      @cards_idx = (0..4).to_a.concat((0..4).to_a).shuffle
      @state = {
        cards_idx: @cards_idx,
        flipped_cards: [],
        matched_pairs: []
      }
    end
  end

  def flip_card(index)
    # Validate the index
    return { error: 'Invalid card index' } unless index.is_a?(Integer) && index >= 0 && index < @cards_idx.length

    if @state[:flipped_cards].any? { |card| card[:index] == index }
      return { status: 'invalid', reason: 'already flipped' }
    end
    if @state[:matched_pairs].flatten.include?(index)
      return { status: 'invalid', reason: 'already matched' }
    end

    # Get the card value at this index
    card_value = @cards_idx[index]

    # Add to flipped cards
    card_value = @cards_idx[index]
    @state[:flipped_cards] << { index: index, value: card_value }

    # Check for matches if we have 2 cards flipped
    if @state[:flipped_cards].length == 2
      card1, card2 = @state[:flipped_cards]

      if card1[:value] == card2[:value]
        @state[:matched_pairs] ||= []
        @state[:matched_pairs] << [card1[:index], card2[:index]]
        result = { match: true }
      else
        result = { match: false }
      end

      @state[:flipped_cards] = []
    else
      result = { waiting: true }
    end

    result
  end

  def game_over?
    @state[:matched_pairs]&.length == 5  # All 5 pairs have been matched
  end
end
