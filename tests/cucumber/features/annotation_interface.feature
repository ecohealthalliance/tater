Feature: Annotation interface

  Background:
    Given there is a test user in the database
    And there is a test group in the database

  @dev
  Scenario: Viewing document in annotation interface
    Given there is a test document in the database
    When I log in as the test user
    And I navigate to the annotation interface for the test document
    Then I should see the test document title
    And I should see the test document body
