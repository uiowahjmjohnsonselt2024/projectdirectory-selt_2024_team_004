require 'rails_helper'

RSpec.describe MatchingGame, type: :model do
  # Tests for validations of instance variables
  before do
    @test_game = MatchingGame.new
  end
  describe 'initialization' do
    it 'should have an array of card indicies of length 10' do
      expect(@test_game.cards_idx.length).to eq(10)
    end
    it 'should have an empty flipped_cards array' do
      expect(@test_game.flipped_cards).to eq([])
    end
    it 'should have an empty matches_idx array' do
      expect(@test_game.matches_idx).to eq([])
    end
  end

  describe 'flipping a card' do
    it 'should contain one flipped card on the first flip' do
      @test_game.flip_card(0)
      expect(@test_game.flipped_cards.length).to eq(1)
    end
    it 'should contain add the match to match_idx on flipping two matching cards' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[0][0])
      @test_game.flip_card(all_matches[0][1])
      expect(@test_game.matches_idx.length).to eq(1)
    end
  end
end