require 'rails_helper'

RSpec.describe MatchingGame, type: :model do
  let(:game) { MatchingGame.new }
  # Create a new game before each test
  before do
    @test_game = MatchingGame.new
  end

  describe 'initialization' do
    it 'should have an array of card indices of length 10' do
      expect(@test_game.cards_idx.length).to eq(10)
    end

    it 'should initialize flipped_cards to an empty state in the game state' do
      expect(@test_game.state[:flipped_cards]).to eq([])
    end

    it 'should initialize matched_pairs to an empty array in the game state' do
      expect(@test_game.state[:matched_pairs]).to eq([])
    end
  end

  describe 'flipping a card' do
    it 'should contain one flipped card in the game state on the first flip' do
      @test_game.flip_card(0)
      expect(@test_game.state[:flipped_cards].length).to eq(1)
    end

    it 'should add a match to matched_pairs on flipping two matching cards' do
      # Find two indices with the same value
      matching_indices = @test_game.cards_idx.each_with_index.group_by(&:first).select { |_k, v| v.size == 2 }.values.first.map(&:last)
      @test_game.flip_card(matching_indices[0])
      @test_game.flip_card(matching_indices[1])
      expect(@test_game.state[:matched_pairs].length).to eq(1)
    end

    it 'should reset flipped_cards to empty after two matching cards are flipped' do
      matching_indices = @test_game.cards_idx.each_with_index.group_by(&:first).select { |_k, v| v.size == 2 }.values.first.map(&:last)
      @test_game.flip_card(matching_indices[0])
      @test_game.flip_card(matching_indices[1])
      expect(@test_game.state[:flipped_cards]).to eq([])
    end

    it 'should not add to matched_pairs when two non-matching cards are flipped' do
      non_matching_indices = @test_game.cards_idx.each_with_index.group_by(&:first).select { |_k, v| v.size == 1 }.values.map(&:last).flatten
      @test_game.flip_card(non_matching_indices[0])
      @test_game.flip_card(non_matching_indices[1])
      expect(@test_game.state[:matched_pairs]).to eq([])
    end

    it 'should return an error hash if the user tries to flip a card that is already flipped' do
      @test_game.flip_card(0)
      attempt = @test_game.flip_card(0)
      expected_output = { reason: "already flipped", status: "invalid" }
      expect(attempt).to eq(expected_output)
    end

    it 'should return an error hash if the user tries to flip a card that is already matched' do
      @test_game.state[:matched_pairs] << [0, 1]
      attempt = @test_game.flip_card(0)
      expected_output = { reason: "already matched", status: "invalid" }
      expect(attempt).to eq(expected_output)
    end
  end

  describe 'game over conditions' do
    it 'should return false when no matches have been made' do
      expect(@test_game.game_over?).to eq(false)
    end

    it 'should return true when all pairs have been matched' do
      game.state[:matched_pairs] = Array.new(5) { [0, 1] }
      expect(game.game_over?).to eq(true)
    end
  end
end
