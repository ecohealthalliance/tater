Feature: Groups

  Background:
    Given there is a test user in the database

  @groups
  Scenario: Creating a new group
    When I log in as the test user
    When I navigate to "/admin"
    Then I should see the "Admin" link highlighted in the header
    When I click the new group link
    And I fill out the new group form with name "Test Group"
    Then I should see a "Success" toast
    And I should see content "Test Group"
    When I click on the group link
    Then I should see content "Test Group"
    And I should not see content "(Code Accessible)"
