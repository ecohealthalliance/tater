Feature: Groups

  Background:
    Given there is a test user in the database

  @groups
  Scenario: Creating a new group
    When I log in as the test user
    When I navigate to "/groups"
    And I click the new group link
    And I fill out the new group form with name "Test Group"
    Then I should see a "Success" toast
    When I navigate to "/groups"
    Then I should see content "Test Group"
    When I click on the group link
    Then I should be on the test group page
    And I should see content "Test Group"

  @groups
  Scenario: Adding a document to a group
    Given there is a test group in the database
    When I log in as the test user
    And I navigate to the test group documents page
    Then I should not see content "Test Document"
    When I click on the New Document link
    And I fill out the new document form with title "Test Document"
    Then I should be on the test group documents page
    And I should see content "Test Document"
    And I should see a "Success" toast

  @groups
  Scenario: Viewing documents as a non-admin
    Given there is a test group in the database
    When I log in as the test user
    And I navigate to the test group page
    And I create an user account for "non@admin.com"
    And I log out
    And I log in as "non@admin.com"
    And I click the documents header link
    Then I should be on the test group documents page
