Given 'the following user exists:' do |table|
  table.hashes.each do |user|
    @user = User.create!(
      name: user['name'],
      email: user['email'],
      password: user['password'],
      password_confirmation: user['password_confirmation']
    )
  end
end

When 'I visit the login page' do
  visit '/login'
end

And 'I log in with email {string} and password {string}' do |email, password|
  email = email.downcase

  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log In'
end

Then 'I should be redirected to the world selection page and see {string}' do |message|
  expect(current_url).to eq(worlds_url(user_id: @user.id))
  expect(page).to have_content(message)
end

Then 'I should remain on the login page and see {string}' do |message|
  expect(current_url).to eq(login_url)
  expect(page).to have_content(message)
end