Feature: Coding Keywords

  Background:
   Given there is a test user in the database

  @coding_keywords
  Scenario: Viewing coding keywords interface
    Given there is a coding keyword with header "Test Header" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"

  @coding_keywords
  Scenario: Add a new code
    When I log in as the test user
    And I navigate to "/editCodingKeywords"
    When I click the Add Keyword button
    And I add the header "GRITS"
    Then I should be able to find "GRITS" in the keyword table
