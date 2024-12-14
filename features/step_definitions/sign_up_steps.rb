Given 'I am on the login page' do
  visit '/login'
end

When 'I click Sign Up' do
  click_link 'Sign Up'
end

Then 'I should be redirected to the sign up page' do
  expect(current_url).to eq(signup_url)
end