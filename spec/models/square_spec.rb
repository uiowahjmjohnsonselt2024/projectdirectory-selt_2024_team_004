require 'rails_helper'

describe Square do
  describe 'Creating a Square object' do
    context 'With a world that already exists' do
      let(:valid_world) do
        world = World.create!(world_name: 'world 1' )
      end
      before do
        valid_world.save
      end
      it 'generates a unique square ID following established hex code expectations' do
        square = Square.create!(world: valid_world)
        expect(square.square_id).to be_present
        expect(square.square_id.length).to eq(20)
      end
      it 'generates unique IDs for different squares' do
        square1 = Square.create!(world: valid_world)
        square2 = Square.create!(world: valid_world)

        expect(square1.square_id).not_to eq(square2.square_id)
      end
      it 'should be able to have many squares in one world' do
        square1 = Square.create!(world: valid_world)
        square2 = Square.create!(world: valid_world)

        expect(valid_world.squares).to include(square1, square2)
      end
      it 'should have the world_id of the world that it belongs to' do
        square1 = Square.create!(world: valid_world)
        expect(square1.world_id).to eq(valid_world.id)
      end
      it 'should have different world_ids for squares in different worlds' do
        square1 = Square.create!(world: valid_world)
        world2 = World.create!(world_name: 'world 2')
        square2 = Square.create!(world: world2)
        expect(square1.world_id).not_to eq(square2.world_id)
      end
      # it 'should call openAI API generate_squares_for_world and include a script tag' do
      #   expect(OpenAI::Client).to receive(:chat).with('prompt')
      #   expect(World.generate_squares_for_world(valid_world)).to include('<script>')
      # end
      
    end
  end
end