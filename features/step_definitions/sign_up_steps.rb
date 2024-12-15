Given 'I am on the login page' do
  visit '/login'
end

When 'I click Sign Up' do
  click_link 'Sign Up'
end

Then 'I should be redirected to the sign up page' do
  expect(current_url).to eq(signup_url)
end

Given 'I am on the sign up page' do
  visit '/signup'
end

And 'I have only filled out the {string} field with {string}' do |field, value|
  fill_in field, with: value
end

When 'I click the Sign Up button' do
  click_button 'Sign Up'
end

Then 'I should remain on the sign up page and see {string}' do |message|
  expect(current_url).to eq(signup_url)
  expect(page).to have_content(message)
end

And 'I have filled out all fields: {string}, {string}, {string}, {string}' do |name, email, password, confirmation|
  fill_in 'Name', with: name
  fill_in "Email", with: email
  fill_in "Password", with: password
  fill_in 'Password confirmation', with: confirmation
end

When 'I click the Log In button' do
  click_link 'Log In'
end

Then 'I should be redirected to the login page' do
  expect(current_url).to eq(login_url)
end

Then 'I should be redirected to the login page and see {string}' do |message|
  expect(current_url).to eq(login_url)
  expect(page).to have_content(message)
end
