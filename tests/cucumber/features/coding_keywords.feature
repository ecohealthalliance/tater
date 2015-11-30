Feature: Coding Keywords

  Background:
    Given there is a test user in the database

  @codingKeywords
  Scenario: Viewing coding keywords interface
    Given there is a coding keyword with header "Test Header" in the database
    And there is a coding keyword with header "Test Header" and sub-header "Test Sub-Header" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see content "Test Keyword"

  @dev
  Scenario: Adding sub-headers on the Coding Keywords page
    Given there is a coding keyword with header "Test Header" in the database
    And there is a coding keyword with header "Test Header" and sub-header "Test Sub-Header" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see content "Test Keyword"
    When I click the Add Sub-Header button
    And I add the sub-header "Bur Bur"
    Then I should see content "Bur Bur"

  @dev
  Scenario: Adding coding keywords on the Coding Keywords page
    Given there are coding keywords in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see content "Test Keyword"
    When I click the add "keyword" button
    And I add the "keyword" "Bur Bur"
    Then I should see content "Bur Bur"
