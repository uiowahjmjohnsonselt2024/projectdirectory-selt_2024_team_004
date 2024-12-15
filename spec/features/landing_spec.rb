require 'rails_helper'
require 'webmock/rspec'

RSpec.feature 'Landing Page', js: true do
  let!(:world) { World.create!(world_name: 'Test World') }
  let!(:user) { User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password', name: 'Test User') }
  let!(:character) { Character.create!(user: user, world: world, x_coord: 0, y_coord: 0, shards: 10, image_code: '1_1_1.png') }
  let!(:squares) do
    (0..5).flat_map do |y|
      (0..5).map do |x|
        Square.create!(world: world, x: x, y: y, state: (x == 0 && y == 0 ? 'active' : 'inactive'))
      end
    end
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit root_path
  end

  scenario 'User opens the store modal from the dropdown menu' do
    find('.dropdown-button', visible: true).click
    click_link 'Store'
    expect(page).to have_selector('#store-modal', visible: true)
  end

  scenario 'User views the purchase modal with item details' do
    find('.dropdown-button', visible: true).click
    click_link 'Store'
    find('.item-button[data-name="Sea Shard (1)"]', visible: true).click
    expect(page).to have_selector('#purchase-modal', visible: true)
    expect(page).to have_content('Sea Shard (1)')
    expect(page).to have_content('Price: $0.75 USD')
  end

  scenario 'User sees the correct grid display on the landing page' do
    expect(page).to have_css('.grid', visible: true)
    expect(page).to have_css('.grid-item', count: 36) # 6x6 grid
  end

  scenario 'User interacts with an active square and moves the character' do
    find('.grid-item[data-state="active"]', visible: true).click
    expect(page).to have_css('.character', visible: true)
  end

  scenario 'User tries to interact with an inactive square and views the popup modal' do
    find('.grid-item[data-state="inactive"]', visible: true).click
    expect(page).to have_selector('#popup-modal', visible: true)
    expect(page).to have_content('Coordinates:')
  end
end
