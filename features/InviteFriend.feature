Feature: Inviting a friend to your world
  As a Sea Raiders user
  So that I can play Sea Raiders with my friends
  I want to be able to send and receive invites from my friends

  Background:
    Given the following user exists:
      | name      | email              | password         | password_confirmation |
      | John      | myUser@example.com | strongPass#123   | strongPass#123        |
      | James     | friend@example.com | thisPass%678     | thisPass%678          |
    And I am on the login page
    And I log in with email "myUser@example.com" and password "strongPass#123"
    And I have added a world with gender "Male" and role "Doctor" and preload "2" and name "My World"

  Scenario: Click invite on an existing world
    Given I am on the worlds page
    And I click the invite button for "My World"
    Then the invite modal should appear
    And the modal should contain the title "Invited Players"
    And the modal should have an email field
    And the modal should have a "Send Invitation" button






    # Make sure to covdr scenerio where user you want to invit doesnt have account
  # Should stay on invite player popup and see "User with that email not found."
  # Try to invite self: "You cannot invite yourself."
  # Successful invite, user sees: "Invitation sent to littlemars22@gmail.com!"
  # Receive invite: should see on page "Pending Invitations" and below that "johndoe@gmail.com invited you to join John's world"
  # Should also have an accept and decline button

  # More scenarios later