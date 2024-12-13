require 'rails_helper'

RSpec.describe 'Landing Page', type: :view do
  before do
    render template: 'squares/landing' # Adjust the template path
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
end
