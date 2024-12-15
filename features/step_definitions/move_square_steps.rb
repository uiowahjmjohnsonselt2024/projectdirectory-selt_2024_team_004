When 'I click on a square with coordinates {int}, {int}' do |x, y|
  square = find(".grid-item[data-x='#{x}'][data-y='#{y}']")
  square.click
end

Then('I should see my character at coordinates {int}, {int}') do |x, y|
  expect(@character.x_coord).to eq(x)
  expect(@character.y_coord).to eq(y)
end

Given("I have a character in the database") do
  # Manually create and save a character
  user = User.first || User.create(email: "myUser@example.com", password: "strongPass#123") # Ensure a user exists
  world = World.first || World.create(world_name: "My World") # Ensure a world exists

  # Create the character with default or specific attributes
  @character = Character.create!(
    character_id: "test_character_1",
    image_code: "1_1_1.png",
    x_coord: 0,
    y_coord: 0,
    shards: 10,
    world_id: world.id,
    user_id: user.id
  )
end