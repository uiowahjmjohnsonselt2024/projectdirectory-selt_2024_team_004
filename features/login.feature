Feature: Login to an existing Sea Raiders user account
  As a Sea Raiders user with an account
  So that I can access my existing game sessions
  I want to login with my email and password and be directed to my world selection page

  Scenario: Successful login
    Given the following user exists:
      | name      | John                |
      | email     | myUser@example.com  |
      | password  | strongPass#123      |
      | password_confirmation | strongPass#123 |
    When I visit the login page
    And I log in with email "myUser@example.com" and password "strongPass#123"
    Then I should be redirected to the world selection page and see "Welcome Back, John!"

