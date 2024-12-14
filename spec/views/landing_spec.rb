require 'rails_helper'

RSpec.describe 'Landing Page', type: :view do
  let(:user) { User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password', name: 'Test User') }
  let(:world) { World.create!(world_name: 'World 1') }
  let(:squares) { [Square.create!(world: world, square_id: 'sq_001', x: 0, y: 0, state: 'inactive')] }
  let(:character) { Character.create!(user: user, world: world, x_coord: 1, y_coord: 1, shards: 10, image_code: '1_1_1.png') }
  let(:prices) { { 'sea_shard_1' => 0.75, 'pile_of_shards_10' => 7.50, 'hat_of_shards_50' => 30.0, 'chest_of_shards_100' => 50.0 } }

  before do
    allow(view).to receive(:current_user).and_return(user)

    assign(:user, user)
    assign(:world, world)
    assign(:squares, squares)
    assign(:character, character)
    assign(:game_result, false)
    assign(:prices, prices)
    render template: 'squares/landing'
  end

  it 'renders the page title' do
    expect(rendered).to have_selector('h2.title', text: 'Pretty Pirates')
  end

  it 'renders the dropdown menu' do
    expect(rendered).to have_selector('.dropdown-menu-container')
    expect(rendered).to have_link('Store', id: 'store-link')
  end

  it 'renders the grid with 36 tiles' do
    expect(rendered).to have_selector('.grid-item', count: 36)
  end

  it 'renders squares with the correct state' do
    squares.each do |square|
      expect(rendered).to have_selector(".grid-item[data-square-id='#{square.square_id}'][data-state='#{square.state}']")
    end
  end

  it 'renders the purchase modal with input fields' do
    expect(rendered).to have_selector('#purchase-modal', visible: false) # Hidden by default
    expect(rendered).to have_selector('form#purchase-form')
    expect(rendered).to have_selector('input#card-number')
    expect(rendered).to have_selector('input#expiration-date')
    expect(rendered).to have_selector('input#cvv')
  end

  it 'displays the correct number of shards for the current user' do
    expect(rendered).to have_selector('.shards-count', text: "Shards: #{character.shards}")
  end
end
