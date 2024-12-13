Feature: Login to an existing Sea Raiders user account
  As a Sea Raiders user with an account
  So that I can access my existing game sessions
  I want to login with my email and password and be directed to my world selection page

  Scenario: Successful login
    Given the following user exists:
      | name      | email              | password         | password_confirmation |
      | John      | myUser@example.com | strongPass#123   | strongPass#123        |
    When I visit the login page
    And I log in with email "myUser@example.com" and password "strongPass#123"
    Then I should be redirected to the world selection page and see "Welcome Back, John!"

  Scenario: Unsuccessful login (invalid password)
    Given the following user exists:
      | name      | email              | password         | password_confirmation |
      | John      | myUser@example.com | strongPass#123   | strongPass#123        |
    When I visit the login page
    And I log in with email "myUser@example.com" and password "wrongPass#123"
    Then I should remain on the login page and see "Invalid email or password"

  Scenario: Unsuccessful login (email with no account)
    When I visit the login page
    And I try to login with an non-existent user email "noAccount@sample.com" and password "fakePass$987"
    Then I should remain on the login page and see "Invalid email or password"
