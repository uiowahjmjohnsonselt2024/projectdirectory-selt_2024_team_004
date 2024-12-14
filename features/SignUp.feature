Feature: Sign up for a new Sea Raiders user account
  As a new Sea Raiders user without an account yet
  So that I can play Sea Raiders
  I want to sign up for a new account with my email, password, and password confirmation

  Scenario: Clicking sign up
    Given I am on the login page
    When I click Sign Up
    Then I should be redirected to the sign up page

  Scenario: Only filling out name
    Given I am on the sign up page
    And I have only filled out the "Name" field with "John"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password can't be blank, Password is too short (minimum is 6 characters), Email can't be blank, Email is invalid, Password confirmation can't be blank"

  Scenario:
  Given I am on the sign up page
  And I have only filled out the "Email" field with "johnDoe@gmail.com"
  When I click the Sign Up button
  Then I should remain on the sign up page and see "Error: Password can't be blank, Password is too short (minimum is 6 characters), Name can't be blank, Password confirmation can't be blank"

    # All sign up scenarios:
  # Only fill out email: "Error: Password can't be blank, Password is too short (minimum is 6 characters), Name can't be blank, Password confirmation can't be blank"
  # Only fill out password: "Error: Password confirmation doesn't match Password, Password confirmation can't be blank, Name can't be blank, Email can't be blank, Email is invalid"
  # Only fill out conf: "Error: Password can't be blank, Password is too short (minimum is 6 characters), Name can't be blank, Email can't be blank, Email is invalid"
  # Password too short: "Error: Password is too short (minimum is 6 characters)"
  # Password and conf dont match: "Error: Password confirmation doesn't match Password"
  # Invalid email: "Email is invalid"
  # Email already used: "Error: Email has already been taken"
  # User clicks Log In to go back to log in page
  # Successful creation, redirected to login page: "Successfully created account!"