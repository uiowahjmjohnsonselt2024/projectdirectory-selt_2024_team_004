require 'rails_helper'

RSpec.describe 'worlds/join.html.erb', type: :view do
  before do
    assign(:user_world_id, 1) # Assign @user_world_id as needed for the view
    render
  end

  it 'renders the character selection title' do
    expect(rendered).to have_selector('h1.character-selection-title', text: 'Create Your Character')
  end

  it "renders the form with hidden fields for selections" do
    expect(rendered).to have_css("input#gender_selection", visible: :hidden)
    expect(rendered).to have_css("input#preload_selection", visible: :hidden)
    expect(rendered).to have_css("input#role_selection", visible: :hidden)
  end

  it 'renders gender selection buttons with the correct active button' do
    expect(rendered).to have_selector("button#male.btn-active[data-group='gender'][data-value='1']", text: 'Male')
    expect(rendered).to have_selector("button#female[data-group='gender'][data-value='2']", text: 'Female')
  end

  it 'renders role selection buttons with the correct active button' do
    expect(rendered).to have_selector("button#captain.btn-active[data-group='role'][data-value='1']", text: 'Captain')
    expect(rendered).to have_selector("button#doctor[data-group='role'][data-value='2']", text: 'Doctor')
    expect(rendered).to have_selector("button#navigator[data-group='role'][data-value='3']", text: 'Navigator')
  end

  it 'renders outfit selection buttons with the correct active button' do
    expect(rendered).to have_selector("button#preload1.btn-active[data-group='preload'][data-value='1']", text: 'Outfit 1')
    expect(rendered).to have_selector("button#preload2[data-group='preload'][data-value='2']", text: 'Outfit 2')
    expect(rendered).to have_selector("button#preload3[data-group='preload'][data-value='3']", text: 'Outfit 3')
  end

  it 'renders the character preview image' do
    expect(rendered).to have_css("div.image-container img[src*='1_1_1']")
  end

  it 'renders the submit button' do
    expect(rendered).to have_selector("input#submit-btn.btn.btn-primary[type='submit'][value='Time to Set Sail!']")
  end

  it 'includes the JavaScript for button interactions and image updates' do
    expect(rendered).to include('document.addEventListener')
    expect(rendered).to include('updateImage')
  end
end
