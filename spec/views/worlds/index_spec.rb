require 'rails_helper'

RSpec.describe 'worlds/index.html.erb', type: :view do
  let(:current_user) { double('User', id: 1, name: 'John Doe') }
  let(:world1) { World.create!(id: 1, world_name: 'Adventure World 1') }
  let(:world2) { World.create!(id: 2, world_name: 'Adventure World 2') }
  let(:user_worlds) do
    [
      double('UserWorld', world_id: world1.id, world: world1),
      double('UserWorld', world_id: world2.id, world: world2)
    ]
  end
  let(:invitations) do
    [
      double('Invitation', sender: double('User', email: 'friend@example.com'),
                           world: double('World', id: 3, world_name: 'Adventure World 3'))
    ]
  end
  let(:invited_players) { { 1 => %w[player1@example.com player2@example.com], 2 => ['player3@example.com'] } }

  before do
    assign(:current_user, current_user)
    assign(:world1, world1)
    assign(:world2, world2)
    assign(:user_worlds, user_worlds)
    assign(:invitations, invitations)
    assign(:invited_players, invited_players)

    render
  end

  it 'displays the user name in the welcome message' do
    expect(rendered).to have_selector('h1', text: 'Welcome Back, John Doe!')
  end

  it 'displays the table of user worlds with Play and Delete buttons' do
    expect(rendered).to have_selector('table.table tbody tr', count: 2)
    expect(rendered).to have_selector('td', text: 'Adventure World 1')
    expect(rendered).to have_selector('td', text: 'Adventure World 2')
    expect(rendered).to have_selector("form[action='#{start_game_path(1)}'] input[type='submit'][value='Play']")
    expect(rendered).to have_selector("form[action='#{start_game_path(2)}'] input[type='submit'][value='Play']")
    expect(rendered).to have_selector("form[action='#{remove_world_path(id: 1)}'][method='post']")
    expect(rendered).to have_selector("form[action='#{remove_world_path(id: 2)}'][method='post']")
  end

  it 'displays the invite button for each world' do
    expect(rendered).to have_selector('button.btn-secondary', text: 'Invite', count: 2)
  end

  it 'displays the invitation modal structure' do
    expect(rendered).to have_selector('#invite-modal')
    expect(rendered).to have_selector('#invite-modal .modal-content h2', text: 'Invited Players')
    expect(rendered).to have_selector('#invite-modal #invited-players-list')
    expect(rendered).to have_selector('#invite-modal form#invite-form input#modal-world-id', visible: :all)
    expect(rendered).to have_selector(
'#invite-modal form#invite-form input[type="text"][placeholder="Enter email to invite"]', visible: :all)
    expect(rendered).to have_selector('#invite-modal form#invite-form input[type="submit"][value="Send Invitation"]', 
visible: :all)
  end

  it 'displays a message if there are no user worlds' do
    assign(:user_worlds, [])
    render
    expect(rendered).to have_selector('p.welcome-message', text: 'Create a world to start!')
  end

  it 'displays the new adventure button if user worlds are less than 3' do
    expect(rendered).to have_selector('form[action="/new_world"] input[type="submit"][value="+"]')
  end

  it 'displays the logout button' do
    expect(rendered).to have_selector('form[action="/logout"] input[type="submit"][value="Logout"]')
  end

  it 'displays pending invitations' do
    expect(rendered).to have_selector('h3', text: 'Pending Invitations')
    expect(rendered).to have_selector('p', text: 'friend@example.com invited you to join Adventure World 3')
    expect(rendered).to have_selector("form[action='#{accept_invitation_path(invitations.first)}'] input[type='submit'][value='Accept']")
    expect(rendered).to have_selector("form[action='#{decline_invitation_path(invitations.first)}'] input[type='submit'][value='Decline']")
  end
end
