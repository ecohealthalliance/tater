Feature: Search Annotations Page

  Background:
    Given there is a test user in the database
    And there is a test group in the database
    And there is a test document in the database
    And there is a test annotation in the database

  @searchAnnotations
  Scenario: Viewing search annotations page
    When I log in as the test user
    And I visit the search annotations page
    Then I should not see the test annotation
    And I select the test group
    Then I should see the test annotation
