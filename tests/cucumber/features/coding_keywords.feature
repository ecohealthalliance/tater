Feature: Coding Keywords

  Background:
    Given there is a test user in the database

  @codingKeywords
  Scenario: Viewing coding keywords interface
    Given there are coding keywords in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see content "Test Keyword"

  @codingKeywords
  Scenario: Adding coding keywords on the Coding Keywords page
    Given there are coding keywords in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click the add "subHeader" button
    And I add the "subHeader" "Another Test Sub-Header"
    And I click on a "sub-header"
    Then I should see content "Test Keyword"
    When I click the add "keyword" button
    And I add the "keyword" "Bur Bur"
    Then I should see content "Bur Bur"
