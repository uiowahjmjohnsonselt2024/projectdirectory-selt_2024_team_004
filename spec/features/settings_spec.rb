require 'rails_helper'

RSpec.describe 'Settings Page', type: :feature do
    before do
      user = User.create!(email: 'test@example.com', password: 'password', name: 'Test User')

      page.driver.header 'Authorization', ActionController::HttpAuthentication::Digest.encode_credentials(
        'GET',
        '/settings',
        'test@example.com',
        'password',
        realm: 'Application'
      )

      allow(OpenExchangeService).to receive(:fetch_currencies).and_return({ 'USD' => 'United States Dollar', 'EUR' => 'Euro' })
      visit settings_path
    end

    scenario "displays the user's name and email address" do
      expect(page).to have_content('Name: Test User')
      expect(page).to have_content('Email: test@example.com')
    end

    scenario "displays the character's picture and role" do
      user = User.create!(email: 'test@example.com', password: 'password', name: 'Test User')
      world = World.create!(name: 'World 1')
      UserWorld.create!(user_id: user.id, world_id: world.id, user_role: 'Captain')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit settings_path(world_id: world.id)

      expect(page).to have_css("img[src='captain.png']")
      expect(page).to have_content('Role: Captain')
    end

    scenario "allows the user to change their default currency" do
      expect(page).to have_content('Default Currency')
      select 'USD', from: 'currency'
      click_button 'Save Settings'
      expect(page).to have_content('Settings saved successfully!')
    end

    scenario 'has a logout button' do
      expect(page).to have_button('Logout')
    end
end
