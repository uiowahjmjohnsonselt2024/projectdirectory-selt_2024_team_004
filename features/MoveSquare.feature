Feature: Moving amongst squares on the landing page
  As a Sea Raiders user with an active world
  So that I can find the treasure
  I want to be able to move squares

  Background:
    Given the following user exists:
      | name      | email              | password         | password_confirmation |
      | John      | myUser@example.com | strongPass#123   | strongPass#123        |
    And I am on the login page
    And I log in with email "myUser@example.com" and password "strongPass#123"
    And I have added a world with gender "Male" and role "Doctor" and preload "2" and name "My World"
    And I have a character in the database
    And I have visited the Landing for "My World" page
    Then I should see "Pretty Pirates"

  Scenario: Clicking on an unlocked square
    When I click on a square with coordinates 3, 3
    Then I should see my character at coordinates 0, 0