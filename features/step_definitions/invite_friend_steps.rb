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

Given 'the following worlds exist:' do |table|
  table.hashes.each do |world|
    # Find a user to associate with the world
    user = User.find_by(email: 'myUser@example.com') # Ensure this user exists

    # Ensure the user is found
    if user
      # Create the world and associate it with the user
      visit new_world_path

      # Fill in the world name
      expect(page).to have_selector("input[name='world_name']", wait: 5)
      find("input[name='world_name']").set(world['world_name'])

      # Set default values for the form
      find('#male').click
      find('#captain').click
      find('#preload1').click

      # Submit the form to create the world
      click_button 'Time to Set Sail!'

      # Associate the world with the user (you may need to modify based on your model)
      created_world = World.find_by(world_name: world['world_name'])
      created_world.update(user: user)
    else
      raise "User not found for world creation"
    end
  end
end

Given 'the following user worlds exist:' do |table|
  table.hashes.each do |user_world|
    user = User.find_by(email: user_world['user_email'].downcase)
    world = World.find_by(world_name: user_world['world_name'])
    UserWorld.create!(user: user, world: world)
  end
end

Given 'I am logged in as {string}' do |email|
  user = User.find_by(email: email)
  visit login_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
end
