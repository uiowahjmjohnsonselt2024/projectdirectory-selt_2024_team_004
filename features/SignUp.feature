Feature: Sign up for a new Sea Raiders user account
  As a new Sea Raiders user without an account yet
  So that I can play Sea Raiders
  I want to sign up for a new account with my name, email, password, and password confirmation

  Scenario: Clicking sign up
    Given I am on the login page
    When I click Sign Up
    Then I should be redirected to the sign up page

  Scenario: Only filling out name
    Given I am on the sign up page
    And I have only filled out the "Name" field with "John"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password can't be blank, Password is too short (minimum is 6 characters), Email can't be blank, Email is invalid, Password confirmation can't be blank"

  Scenario: Only filling out email
    Given I am on the sign up page
    And I have only filled out the "Email" field with "johnDoe@gmail.com"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password can't be blank, Password is too short (minimum is 6 characters), Name can't be blank, Password confirmation can't be blank"

  Scenario: Only filling out password
    Given I am on the sign up page
    And I have only filled out the "Password" field with "myPassword#10"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password confirmation doesn't match Password, Password confirmation can't be blank, Name can't be blank, Email can't be blank, Email is invalid"

  Scenario: Only filling out password confirmation
    Given I am on the sign up page
    And I have only filled out the "Password confirmation" field with "strongPass$456"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password can't be blank, Password is too short (minimum is 6 characters), Name can't be blank, Email can't be blank, Email is invalid"
  
  Scenario: Password is too short
    Given I am on the sign up page
    And I have filled out all fields: "John", "johndoe@gmail.com", "a", "a"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password is too short (minimum is 6 characters)"

  Scenario: Password does not match password confirmation
    Given I am on the sign up page
    And I have filled out all fields: "Emily", "emily_82@gmail.com", "password#286", "Password$268"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Password confirmation doesn't match Password"

  Scenario: Invalid email given
    Given I am on the sign up page
    And I have filled out all fields: "Zach", "z_murphy#notAnEmail", "goodPassword%567", "goodPassword%567"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Email is invalid"
  
  Scenario: Email already has an account
    Given the following user exists:
      | name      | email              | password         | password_confirmation |
      | John      | myUser@example.com | strongPass#123   | strongPass#123        |
    And I am on the sign up page
    And I have filled out all fields: "John", "myUser@example.com", "johnsPass&2", "johnsPass&2"
    When I click the Sign Up button
    Then I should remain on the sign up page and see "Error: Email has already been taken"

  Scenario: User clicks Log In to go back to the login page
    Given I am on the sign up page
    When I click the Log In button
    Then I should be redirected to the login page

  Scenario: Successful creation of a new user
    Given I am on the sign up page
    And I have filled out all fields: "Mackenzie", "mack_ryan@gmail.com", "abcDEF%926", "abcDEF%926"
    When I click the Sign Up button
    Then I should be redirected to the login page and see "Successfully created account!"
  

    # All sign up scenarios:
  # Successful creation, redirected to login page: "Successfully created account!"