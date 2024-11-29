Given("there is a test user") do
  User.find_or_create_by!(email: 'test@example.com') do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.name = 'Test User'
  end
end

Given("I am logged in") do
  # First ensure we have a test user
  step "there is a test user"
  
  visit login_path
  fill_in 'email', with: 'test@example.com'
  fill_in 'password', with: 'password123'
  click_button 'Log In'
  
  # Add debugging to verify login worked
  puts "After login, current path: #{current_path}"
  expect(current_path).not_to eq('/login')
end

When("I have created a new world with name {string}") do |world_name|
  visit new_world_path
  
  # Debug output
  puts "Current path: #{current_path}"
  
  # Wait for and fill in the form
  expect(page).to have_selector("input[name='world_name']", wait: 5)
  find("input[name='world_name']").set(world_name)
  
  # Set default values for the form
  find('#male').click
  find('#captain').click
  find('#preload1').click
  
  # Debug before submission
  puts "About to submit form with world name: #{world_name}"
  
  click_button 'Time to Set Sail!'
  
  # Debug after submission
  puts "After submission, current path: #{current_path}"
  puts "Page content:"
  puts page.html
end

Then("I should see a World list entry with buttons to play and delete with name {string}") do |name|
  # Debug output
  puts "Checking for world with name: #{name}"
  
  result = false
  all("tr").each do |tr|
    puts "Checking row: #{tr.text}"
    if tr.has_content?(name) && 
       tr.has_selector?("input[value='Play']") && 
       tr.has_selector?("input[value='Delete']")
      result = true
      break
    end
  end
  expect(result).to be_truthy, "Could not find world entry with name '#{name}' and required buttons"
end

When("I am on the worlds page") do
  visit worlds_path
end

Then /^I should see a world list entry with name "(.?)"$/ do |name|
  result=false
  all("tr").each do |tr|
    if tr.has_content?(name) && tr.has_content?("Play") && tr.has_content?("Delete")
      result = true
      break
    end
  end  
  expect(result).to be_truthy
end


When("I have visited the Landing page") do |name|
  visit worlds_path
  click_on "Play"
end

Then /^(?:|I )should see "([^\"]*)"$/ do |text|
  expect(page).to have_content(text)
end

Given("I have added a world with gender {string} and role {string} and preload {string} and name {string}") do |gender, role, preload, name|
  visit new_world_path
  
  # Fill in the world name
  find("input[name='world_name']").set(name)
  
  # Click the appropriate gender button
  find("##{gender.downcase}").click
  
  # Click the appropriate role button
  find("##{role.downcase}").click
  
  # Click the appropriate preload button
  find("#preload#{preload}").click
  
  # Submit the form
  click_button 'Time to Set Sail!'
end

When("I have visited the Landing for {string} page") do |world_name|
  visit worlds_path
  within("tr", text: world_name) do
    click_button "Play"
  end
end


When("I delete the world with name {string}") do |world_name|
  visit worlds_path
  within("tr", text: world_name) do
    click_button "Delete"
  end
end

Then("I should not see a World list entry with buttons to play and delete with name {string}") do |world_name|
  expect(page).not_to have_content(world_name)
end

