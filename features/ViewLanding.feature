Feature: View Landing Page for a World

  Scenario: Click on the "Play" link for a world to view the game
    Given there is a test user
    And I am logged in
    And I have added a world with gender "Male" and role "Captain" and preload "1" and name "Test World"
    When I have visited the Landing for "Test World" page
    Then I should see "Pretty Pirates"