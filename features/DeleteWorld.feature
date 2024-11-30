Feature: Allow Sea Raiders user to delete a world

Scenario:  Delete a world (Declarative)
  Given there is a test user
  And I am logged in
  When I have created a new world with name "World 4"
  And I am on the worlds page  
  Then I should see a World list entry with buttons to play and delete with name "World 4"
  When I delete the world with name "World 4"
  And I am on the worlds page  
  Then I should not see a World list entry with buttons to play and delete with name "World 4"
