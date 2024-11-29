require 'rails_helper'

RSpec.describe MatchingGame, type: :model do
  # Create a new game before each test
  before do
    @test_game = MatchingGame.new
  end

  # Tests for verifying correct instantiation of instance variables
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

  # Tests for verifying desired behavior when flipping cards under different scenarios
  describe 'flipping a card' do
    it 'should contain one flipped card on the first flip' do
      @test_game.flip_card(0)
      expect(@test_game.flipped_cards.length).to eq(1)
    end
    it 'should contain add the match to matches_idx on flipping two matching cards' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[0][0])
      @test_game.flip_card(all_matches[0][1])
      expect(@test_game.matches_idx.length).to eq(1)
    end
    it 'should reset flipped_cards to empty on flipping two matching cards' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[0][0])
      @test_game.flip_card(all_matches[0][1])
      expect(@test_game.flipped_cards.length).to eq(0)
    end
    it 'should have an empty matches_idx and flipped_cards array when two non-matches are flipped' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[0][0])
      @test_game.flip_card(all_matches[2][1])
      expect(@test_game.matches_idx.length).to eq(0)
    end
    it 'should have an empty flipped_cards array when two non-matches are flipped' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[0][0])
      @test_game.flip_card(all_matches[2][1])
      expect(@test_game.flipped_cards.length).to eq(0)
    end
    it 'should contain some matches in matches_idx and an empty flipped_cards after making some matches and flipping an even number of cards' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[1][0])
      @test_game.flip_card(all_matches[1][1])
      @test_game.flip_card(all_matches[4][0])
      @test_game.flip_card(all_matches[4][1])
      expect(@test_game.matches_idx.length).to eq(2)
      expect(@test_game.flipped_cards.length).to eq(0)
    end
    it 'should contain some matches in matches_idx and one card in flipped_cards after making some matches and flipping an odd number of cards' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[2][1])
      @test_game.flip_card(all_matches[2][0])
      @test_game.flip_card(all_matches[0][0])
      @test_game.flip_card(all_matches[0][1])
      @test_game.flip_card(all_matches[3][0])
      @test_game.flip_card(all_matches[3][1])
      @test_game.flip_card(all_matches[4][1])
      expect(@test_game.matches_idx.length).to eq(3)
      expect(@test_game.flipped_cards.length).to eq(1)
    end
    it 'should return nil if the user tries to flip a card that is already flipped' do
      @test_game.flip_card(0)
      attempt = @test_game.flip_card(0)
      expect(attempt).to be_nil
    end
    it 'should return nil if the user tries to flip a card that is already matched' do
      all_matches = @test_game.get_matches
      @test_game.flip_card(all_matches[1][1])
      @test_game.flip_card(all_matches[1][0])
      attempt = @test_game.flip_card(all_matches[1][1])
      expect(attempt).to be_nil
    end
  end

  describe 'calling game_over?' do
    it 'should return false if user has done nothing yet' do
      game_state = @test_game.game_over?
      expect(game_state).to eq(false)
    end
  end
end