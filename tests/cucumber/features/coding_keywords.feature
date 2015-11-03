Feature: Documents

  Background:
    Given there is a test user in the database

  @coding_keywords
  Scenario: Add a new code
    When I log in as the test user
    And I navigate to "/editCodingKeywords"
    When I click the Add Keyword button
    And I add the header "GRITS"
    Then I should be able to find "GRITS" in the keyword table

  @coding_keywords
  Scenario: Add a new code for a group
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    When I navigate to "/admin"
    Then I should see content "Test Group"
    When I click on the group link
    When I click the Add Keyword button
    And I add the header "Ecology"
    Then I should be able to find "Ecology" in the keyword table
    When I navigate to the annotation interface for the test document
    Then I should see "Ecology" in the coding keywords panel
