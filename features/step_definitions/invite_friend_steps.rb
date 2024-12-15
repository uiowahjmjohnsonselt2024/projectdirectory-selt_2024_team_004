When 'I click the invite button for {string}' do |world_name|
  within('tr', text: world_name) do
    click_button 'Invite'
  end
end

Then 'the invite modal should appear' do
  expect(page).to have_css('#invite-modal', visible: true)
end

Then 'the modal should contain the title {string}' do |title|
  within('#invite-modal') do
    expect(page).to have_content(title)
  end
end

Then 'the modal should have an email field' do
  within('#invite-modal') do
    expect(page).to have_field('Enter email to invite')
  end
end

Then 'the modal should have a {string} button' do |button_text|
  within('#invite-modal') do
    expect(page).to have_button(button_text)
  end
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string}') do |button_text|
  click_button button_text
end

Then("I should see the error message {string} in the invite modal") do |error_message|
  expect(page).to have_content(error_message)
end

Then 'the modal should remain up' do
  expect(page).to have_css('#invite-modal', visible: true)
end

#Then "the invitation to {string} for {string} should be sent" do |email, world_name|
#  # Find the user by email
#  user = User.find_by(email: email)
#
#  # Ensure the user exists
#  expect(user).not_to be_nil
#
#  # Find the world by name
#  world = World.find_by(world_name: world_name)
#
#  # Ensure the world exists
#  expect(world).not_to be_nil
#
#  # Check if the invitation was created
#  invitation = Invitation.find_by(sender_id: user.id, world_id: world.id, status: 'pending')
#
#  # Ensure the invitation exists
#  expect(invitation).not_to be_nil
#end