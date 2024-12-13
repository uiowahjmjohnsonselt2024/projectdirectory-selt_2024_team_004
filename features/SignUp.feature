Feature: Sign up for a new Sea Raiders user account
  As a new Sea Raiders user without an account yet
  So that I can play Sea Raiders
  I want to sign up for a new account with my email, password, and password confirmation

  Scenario: Clicking sign up
    Given I am on the login page
    When I click Sign Up
    Then I should be redirected to the sign up page