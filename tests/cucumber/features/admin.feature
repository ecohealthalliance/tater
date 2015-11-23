Feature: Admin page

  Background:
    Given there is a test user in the database
    And the user is not logged in

  @admin
  Scenario: Viewing user profiles as an admin
    Given there is a test group in the database
    When I log in as the test user
    And I navigate to "/profile/edit"
    When I fill out the profile edit form with fullName "Test Name"
    Then I should see a "Success" toast

    When I navigate to the admin page
    Then I should see the "Admin" link highlighted in the header
    When I click on the test user
    Then I should be on the user profile page
    And I should see content "Test Name"
    And I should see content "test@example.com"
