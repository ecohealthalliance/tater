@dev
Feature: Annotation interface
  Background:
    Given there is a test user in the database
    And there is a test group in the database

  @annotations
  Scenario: Viewing document in annotation interface
    Given there is a test document in the database
    When I log in as the test user
    And I navigate to the annotation interface for the test document
    Then I should see the test document title
    And I should see the test document body

  @annotations
  Scenario: Viewing coding keywords in annotation interface
    Given there is a test document in the database
    And there is a coding keyword with header "Test" in the database
    When I log in as the test user
    And I navigate to the annotation interface for the test document
    Then I should not see an annotation in the annotations list

    When I highlight some document text
    And I click on a coding keyword
    Then I should see an annotation in the annotations list

  @annotations
  Scenario: Searching for coding keywords in annotation interface
    Given there is a test document in the database
    And there is a coding keyword with header "Test" in the database
    When I log in as the test user
    And I navigate to the annotation interface for the test document

    And I type "ASDF" in the coding keyword search
    Then I should not see coding keyword search results

    When I type "Test" in the coding keyword search
    Then I should see coding keyword search results

  @annotations
  Scenario: Clicking highlighted text should take you to the annotation
    Given there is a test document in the database
    And there is a coding keyword with header "Test" in the database
    When I log in as the test user
    And I navigate to the annotation interface for the test document
    And I highlight some document text
    And I click on a coding keyword
    And I click on some highlighted text
    Then the annotation should be selected
