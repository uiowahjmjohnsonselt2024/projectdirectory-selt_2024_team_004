require 'rails_helper'

RSpec.feature 'Landing Page', js: true do
  scenario 'User opens the store modal from the dropdown menu' do
    visit root_path
    find('.dropdown-button').click
    click_link 'Store'
    expect(page).to have_selector('#store-modal', visible: true)
  end

  scenario 'User views the purchase modal with item details' do
    visit root_path
    find('.dropdown-button').click
    click_link 'Store'
    find('.item-button[data-name="Sea Shard (1)"]').click

    expect(page).to have_selector('#purchase-modal', visible: true)
    expect(page).to have_content('Sea Shard (1)')
    expect(page).to have_content('Price: $0.75 USD')
  end
end
