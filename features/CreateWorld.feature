Feature: Allow Sea Raiders user to create a new world

Scenario:  Create a new world (Declarative)
  Given there is a test user
  And I am logged in
  When I have created a new world with name "World 4"
  And I am on the worlds page  
  Then I should see a World list entry with buttons to play and delete with name "World 4"


Scenario: Click create world
  Given there is a test user
  And I am logged in
  And I am on the worlds page
  When I click the plus button
  Then I am redirected to the create world page

