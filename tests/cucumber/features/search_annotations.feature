Feature: Search Annotations Page

  Background:
    Given there is a test user in the database
    And there is a test group in the database
    And there is a test document in the database

  @searchAnnotations
  Scenario: Viewing search annotations page
    Given there is a test annotation in the database
    When I log in as the test user
    And I visit the search annotations page
    Then I should not see the test annotation
    And I select the test group
    Then I should see the test annotation

  @dev
  Scenario: Viewing search annotations page
    Given there are 30 test annotations in the database
    When I log in as the test user
    And I visit the search annotations page
    And I select the test group
    Then I should see 20 test annotations
    And I should see the next page button

    When I go to the next page of annotations
    Then I should see 10 test annotations
    And I should not see the next page button
    And I should see the previous page button

    When I go to the previous page of annotations
    Then I should see 20 test annotations
    And I should not see the previous page button
