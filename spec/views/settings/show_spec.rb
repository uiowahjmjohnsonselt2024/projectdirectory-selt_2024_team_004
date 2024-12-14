require 'rails_helper'

RSpec.describe 'settings/show.html.erb', type: :view do
  let(:user) { double('User', id: 1, name: 'John Doe', email: 'john.doe@example.com', default_currency: 'USD') }
  let(:currencies) { { 'USD' => 'US Dollar', 'EUR' => 'Euro' } }
  let(:character) { double('Character') }
  let(:character_image) { '1_1_1.png' }
  let(:role) { 'Captain' }

  before do
    assign(:user, user)
    assign(:current_user, user)
    assign(:currencies, currencies)
    assign(:character, character)
    assign(:character_image, character_image)
    assign(:role, role)
  end

  context 'when character is present' do
    before { assign(:character, true) }

    it 'displays the account information' do
      render
      expect(rendered).to have_selector('h2', text: 'Account Information')
      expect(rendered).to have_selector('p', text: 'Name: John Doe')
      expect(rendered).to have_selector('p', text: 'Email: john.doe@example.com')
    end

    it 'displays the character section with role and image' do
      render
      expect(rendered).to have_selector('h2', text: 'Character')
      expect(rendered).to have_selector('p', text: 'Role: Captain')
      expect(rendered).to have_selector("img[alt='Character Image'][src*='1_1_1']")
    end
  end

  context 'when character is not present' do
    before { assign(:character, false) }

    it 'displays a message for no character available' do
      render
      expect(rendered).to have_selector('p', text: 'No character available.')
    end
  end

  context 'when currencies are present' do
    it 'displays the currency dropdown and save button' do
      render
      expect(rendered).to have_selector('h2', text: 'Default Currency')
      expect(rendered).to have_selector('select.currency-dropdown')
      expect(rendered).to have_selector("input[type='submit'][value='Save Settings']")
    end
  end

  context 'when currencies are not present' do
    before { assign(:currencies, nil) }

    it 'displays a message that currency options could not be loaded' do
      render
      expect(rendered).to have_selector('p', text: 'Currency options could not be loaded. Please try again later.')
    end
  end

  it 'displays the back to game button' do
    render
    expect(rendered).to have_selector("form.button_to[action='/landing?user_id=1'][method='get']")
    expect(rendered).to have_selector("input.landing-button[type='submit'][value='Back to Game']")
  end

  it 'displays the logout button' do
    render
    expect(rendered).to have_selector("form.button_to[action='/logout'][method='post']")
    expect(rendered).to have_selector("input[name='_method'][value='delete']", visible: :all)
    expect(rendered).to have_selector("input.logout-button[type='submit'][value='Logout']")
  end
end
