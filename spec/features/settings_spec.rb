require 'rails_helper'
def login_user(user)
  visit login_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'password'
  click_button 'Log In'
end

def login_user(user)
  visit login_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'password'
  click_button 'Log In'
end

RSpec.describe 'Settings Page', type: :feature do
  let(:user) do
 User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password', name: 'Test User') end
  let(:world) { World.create!(world_name: 'World 1') }
  let!(:character) do
    Character.create!(
      user_id: user.id,
      world_id: world.id,
      x_coord: 0,
      y_coord: 0,
      shards: 5,
      image_code: '1_1_1.png'
    )
  end

  before do
    UserWorld.create!(user_id: user.id, world_id: world.id, user_role: 'Captain')
    allow(OpenExchangeService).to receive(:fetch_currencies).and_return({ 'USD' => 'United States Dollar',
                                                                          'EUR' => 'Euro' })
    allow_any_instance_of(ApplicationController).to receive(:session).and_return(
      user_id: user.id,
      world_id: world.id,
      character_id: character.id
    )
    login_user(user)
    visit settings_path(user_id: user.id, world_id: world.id, character_id: character.id)
  end

  scenario "displays the user's name and email address" do
    expect(page).to have_content('Name: Test User')
    expect(page).to have_content('Email: test@example.com')
  end

  scenario "displays the character's picture and role" do
    UserWorld.create!(user_id: user.id, world_id: world.id, user_role: 'Captain')

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit settings_path(world_id: world.id)

    expect(page).to have_css("img[src*='1_1_1']")
    expect(page).to have_content('Role: Captain')
  end

  scenario 'allows the user to change their default currency' do
    expect(page).to have_content('Default Currency')
    select 'USD', from: 'currency'
    click_button 'Save Settings'

    visit settings_path(user_id: user.id, world_id: world.id)

    expect(page).to have_current_path(settings_path(user_id: user.id, world_id: world.id))
  end

  scenario 'has a logout button' do
    expect(page).to have_button('Logout')
  end
end
