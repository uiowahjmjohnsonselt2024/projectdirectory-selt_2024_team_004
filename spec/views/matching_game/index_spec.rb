require 'rails_helper'

RSpec.describe 'matching_game/index.html.erb', type: :view do
  let(:user) { double('User', id: 1) }
  let(:world) { double('World', id: 1) }
  let(:square_id) { 42 }
  let(:shuffled_cards) { Array.new(10) { rand(0..4) } }

  before do
    assign(:user, user)
    assign(:world, world)
    assign(:square_id, square_id)
    assign(:shuffled_cards, shuffled_cards)
  end

  it 'displays the CSRF and CSP meta tags' do
    allow(view).to receive(:csrf_meta_tags).and_return('<meta name="csrf-token" content="test-csrf-token">')
    allow(view).to receive(:csp_meta_tag).and_return('<meta name="csp-nonce" content="test-csp-nonce">')

    render
    expect(rendered).to include('&lt;meta name=&quot;csrf-token&quot; content=&quot;test-csrf-token&quot;&gt;')
    expect(rendered).to include('&lt;meta name=&quot;csp-nonce&quot; content=&quot;test-csp-nonce&quot;&gt;')
  end

  it 'includes a hidden field for square_id' do
    render
    expect(rendered).to have_selector("input[name='square_id'][type='hidden'][value='#{square_id}']", visible: :all)
  end

  it 'displays the top banner with a title and dropdown menu' do
    render
    expect(rendered).to have_selector('.top-banner h2.title', text: 'Matching Mateys!')
    expect(rendered).to have_selector('.dropdown-menu-container .dropdown-button', text: 'Menu')
    expect(rendered).to have_link(
      'Quit Minigame',
      href: landing_path(world_id: world.id, user_id: user.id),
      class: 'btn btn-primary dropdown_link'
    )
  end

  it 'displays the timer and start button' do
    render
    expect(rendered).to have_selector('.timer', text: '01:00')
    expect(rendered).to have_selector('button.start-btn', text: 'Set Sail!')
  end

  it 'displays the game over message (hidden by default)' do
    render
    expect(rendered).to have_selector('#game-over-message', text: 'ARG!!! Yer game is over!', visible: false)
    expect(rendered).to have_selector(
      '#game-over-message .redirect-message',
      text: 'Now, BACK TO YER LANDING PAGE, SCALLYWAG!!',
      visible: false
    )
  end

  it 'displays the game won message (hidden by default)' do
    render
    expect(rendered).to have_selector('#game-won-message', text: 'SHIVER ME TIMBERS! Ye claimed victory!',
                                                           visible: false)
    expect(rendered).to have_selector(
      '#game-won-message .redirect-message',
      text: 'Redirecting ye back to the landing page...',
      visible: false
    )
  end

  it 'displays the cards in 2 rows of 5' do
    render
    expect(rendered).to have_selector('.cards-container .card-row', count: 2)
    expect(rendered).to have_selector('.cards-container .card', count: 10)

    shuffled_cards.each_with_index do |card_index, index|
      expect(rendered).to have_selector(
        ".card[data-card='#{index}'] img[src*='card_image#{card_index + 1}']",
        visible: :all
      )
    end
  end

  it 'displays the game description' do
    render
    expect(rendered).to have_selector('.description-container .description', text: /Ahoy matey!/)
  end

  it 'passes shuffled cards to JavaScript' do
    render
    expect(rendered).to include(shuffled_cards.to_json)
  end

  it 'renders valid JavaScript and CSS' do
    render
    expect(rendered).to include('<script>')
    expect(rendered).to include('<style>')
  end
end
