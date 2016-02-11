Feature: Accounts

  @accounts
  Scenario: Editing my profile
    Given there is a test user in the database
    When I log in as the test user
    And I navigate to "/profile/edit"
    When I fill out the profile edit form as "John Doe"
    Then I should see a "Success" toast
    When I view my public profile
    And I should see content "John Doe"

  @accounts
  Scenario: Viewing a public profile
    Given there is a profile with ID 'fakeid' where "fullName" is "John Doe"
    And there is a test user in the database
    When I log in as the test user
    And I navigate to "/profiles/fakeid"
    Then I should see content "John Doe"

  @accounts
  Scenario: Creating an account for another user
    Given there is a test user in the database
    And there is a group in the database
    When I log in as the test user
    And I navigate to the admin page
    And I create a user account for "mr@potato.head"
    And I log out
    And I log in as "mr@potato.head"
    Then I am logged in

  @accounts
  Scenario: Creating an account for another admin user
    Given there is a test user in the database
    When I log in as the test user
    And I navigate to the admin page
    And I create an admin user account for "mr@potato.head"
    And I log out
    And I log in as "mr@potato.head"
    Then I am logged in
    And I am logged in as an admin user

  @accounts
  Scenario: Deleting a user account
    Given there is a test user in the database
    And there is a group in the database
    When I log in as the test user
    And I navigate to the admin page
    And I create a user account for "mr@potato.head"
    Then I should see content "mr@potato.head"
    When I click the remove user link
    And I confirm the account deletion
    Then I should not see content "mr@potato.head"

  @accounts
  Scenario: Changing my password
    Given there is a test user in the database
    When I log in as the test user
    And I open the change password modal
    And I fill out the change password form
    Then I should see a "Success" toast
    And I log out
    And I log in with my new password
    Then I am logged in

  @dev
  Scenario: Automatic logging in using url parameters
    When there is a test user in the database with an access token
    And I am not logged in
    Then I log in by passing a secret access token via URL
    And I am logged in

  @dev
    Scenario: Failing automatic logging in using url parameter
      When there is a test user in the database
      And I log in as the test user
      Then I am logged in
      And I log out
      Then I log in by passing a secret access token via URL
      And I am not logged in
