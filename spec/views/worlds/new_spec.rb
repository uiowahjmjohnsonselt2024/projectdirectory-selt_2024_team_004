require 'rails_helper'

RSpec.describe 'worlds/new.html.erb', type: :view do
  before do
    render
  end

  describe 'form structure' do
    it 'renders the form with the correct action and method' do
      expect(rendered).to have_selector('form.character-selection-form[action="/world"][method="post"]')
    end

    it 'renders hidden fields for gender, preload, and role selections' do
      expect(rendered).to have_selector('input#gender_selection[type="hidden"][name="gender"]', visible: :all)
      expect(rendered).to have_selector('input#preload_selection[type="hidden"][name="preload"]', visible: :all)
      expect(rendered).to have_selector('input#role_selection[type="hidden"][name="role"]', visible: :all)
    end

    it 'renders the loading text hidden by default' do
      expect(rendered).to have_selector('.loading-text', text: /Creating world/, visible: :all)
    end
  end

  describe 'button groups' do
    it 'renders gender selection buttons with correct attributes and classes' do
      expect(rendered).to have_selector('button#male[data-group="gender"][data-value="1"].btn-active', text: 'Male')
      expect(rendered).to have_selector('button#female[data-group="gender"][data-value="2"]', text: 'Female')
    end

    it 'renders role selection buttons with correct attributes and classes' do
      expect(rendered).to have_selector('button#captain[data-group="role"][data-value="1"].btn-active', text: 'Captain')
      expect(rendered).to have_selector('button#doctor[data-group="role"][data-value="2"]', text: 'Doctor')
      expect(rendered).to have_selector('button#navigator[data-group="role"][data-value="3"]', text: 'Navigator')
    end

    it 'renders preload selection buttons with correct attributes and classes' do
      expect(rendered).to have_selector('button#preload1[data-group="preload"][data-value="1"].btn-active', text: 'Outfit 1')
      expect(rendered).to have_selector('button#preload2[data-group="preload"][data-value="2"]', text: 'Outfit 2')
      expect(rendered).to have_selector('button#preload3[data-group="preload"][data-value="3"]', text: 'Outfit 3')
    end
  end

  describe 'image container' do
    it 'renders the image container with the correct initial image' do
      expect(rendered).to match(%r{<img src="/assets/1_1_1-[a-z0-9]+\.png" />})
    end
  end

  describe 'submit button' do
    it 'renders the submit button with correct text' do
      expect(rendered).to have_selector('input#submit-btn[type="submit"][value="Time to Set Sail!"]')
    end
  end

  describe 'JavaScript functionality' do
    it 'includes JavaScript for setting default selections' do
      expect(rendered).to include('document.getElementById("gender_selection").value = defaultSelections.gender;')
    end

    it 'includes JavaScript for updating the character image' do
      expect(rendered).to include('function updateImage() {')
      expect(rendered).to include('imageContainer.src = "/assets/" + imagePath;')
    end

    it 'includes JavaScript for submit button loading animation' do
      expect(rendered).to include('submitBtn.style.display =')
      expect(rendered).to include('loadingText.style.display =')
      expect(rendered).to include('dots.textContent = \'.\'.repeat(dotCount);')
    end
  end
end
