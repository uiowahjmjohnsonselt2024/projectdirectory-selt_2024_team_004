require 'rails_helper'

RSpec.describe Character, type: :model do
  describe 'validations' do
    context 'With a properly instantiated World and Character' do
      let(:valid_world) do
        World.new(
          world_name: 'World 1',
          last_played: DateTime.new(2024, 11, 29, 10, 0, 0),
          progress: 0
        )
      end
      let(:valid_character) do
        Character.new(
          image_code: '1_1_1.png',
          shards: 10,
          x_coord: 0,
          y_coord: 0,
          world: valid_world,
        )
      end
      it 'character should be valid with valid instance variables' do
        expect(valid_character).to be_valid
      end
      it 'generates a unique character ID following established hex code expectations' do
        character = Character.create!(world: valid_world)
        expect(character.character_id).to be_present
        expect(character.character_id.length).to eq(20)
      end
      it 'generates unique character IDs for different characters' do
        character1 = Character.create!(world: valid_world)
        character2 = Character.create!(world: valid_world)

        expect(character1.character_id).not_to eq(character2.character_id)
      end
      it 'should belong to world' do
        character = Character.create!(world: valid_world)

        expect(character.world).to eq(valid_world)
      end
    end
  end
end