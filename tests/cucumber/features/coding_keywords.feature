Feature: Coding Keywords
  Background:
    Given there is a test user in the database
    And there is a test group in the database
    And there is a test document in the database

  @codingKeywords
  Scenario: Viewing coding keywords interface
    Given there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see content "Test Keyword"

  @codingKeywords
  Scenario: Deleting headers
    Given there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see 1 keyword
    When I delete a keyword
    And I delete a sub-header
    Then I should see 0 sub-headers
    When I delete a header
    Then I should see 0 headers

  @codingKeywords
  Scenario: Deleting sub-headers
    Given there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see 1 keyword
    When I delete a keyword
    And I delete a sub-header
    Then I should see 0 sub-headers

  @codingKeywords
  Scenario: Deleting coding keywords
    Given there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword2" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see 2 keywords
    When I delete a keyword
    Then I should see 1 keyword

  @codingKeywords
  Scenario: Adding coding keywords
    Given there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    When I add the "header" "Another Test Header"
    Then I should see content "Another Test Header"
    When I click on a "header"
    And I add the "subHeader" "Another Test Sub-Header"
    Then I should see content "Another Test Sub-Header"
    When I click on a "subHeader"
    And I add the "keyword" "Another Test Keyword"
    Then I should see content "Another Test Keyword"

  @codingKeywords
  Scenario: Archiving coding keywords that are in use
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword2" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword3" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see 3 keywords
    And I should see 0 archived keywords
    When I delete a keyword
    Then I should see 2 keywords
    And I should see 1 archived keywords
    When I navigate to "/documents"
    And I click the first document
    Then I should see 2 keywords
    And I should see 0 annotations

  @dev
  Scenario: Archiving sub-headers that are in use
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword2" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword3" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header2" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see 3 keywords
    And I should see 0 archived keywords
    When I delete a sub-header
    Then I should see 1 sub-headers
    And I should see 1 archived sub-headers
    And I should see 1 archived keywords
    When I navigate to "/documents"
    And I click the first document
    Then I should see 1 keywords
    And I should see 0 annotations


  @dev
  Scenario: Archiving headers that are in use
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword2" in the database
    And there is a coding keyword with header "Test Header", sub-header "Test Sub-Header" and keyword "Test Keyword3" in the database
    And there is a coding keyword with header "Test Header 2", sub-header "Test Sub-Header" and keyword "Test Keyword" in the database
    When I log in as the test user
    And I navigate to "/codingKeywords"
    Then I should see content "Test Header"
    When I click on a "header"
    Then I should see content "Test Sub-Header"
    When I click on a "sub-header"
    Then I should see 3 keywords
    And I should see 0 archived keywords
    When I delete a header
    Then I should see 1 archived sub-headers
    And I should see 1 archived keywords
    When I navigate to "/documents"
    And I click the first document
    Then I should see 1 keywords
    And I should see 0 annotations

  @codingKeywords
  Scenario: Unarchiving coding keywords that have been archived
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    When I log in as the test user
    And I navigate to "/codingKeywords"
    When I click on a "header"
    And I click on a "sub-header"
    Then I should see 1 keywords
    And I should see 0 archived keywords
    When I delete a keyword
    Then I should see 0 keywords
    And I should see 1 archived keywords
    When I unarchive a keyword
    Then I should see 1 keywords
    And I should see 0 archived keywords
    When I navigate to "/documents"
    And I click the first document
    Then I should see 1 keywords
    And I should see 1 annotations

  @codingKeywords
  Scenario: Unarchiving sub-headers that have been archived
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    When I log in as the test user
    And I navigate to "/codingKeywords"
    When I click on a "header"
    When I click on a "sub-header"
    Then I should see 1 keywords
    And I should see 0 archived keywords
    When I delete a sub-header
    Then I should see 0 sub-headers
    And I should see 1 archived sub-headers
    And I should see 1 archived keywords
    When I unarchive a sub-header
    Then I should see 1 sub-headers
    When I navigate to "/documents"
    And I click the first document
    Then I should see 1 keywords
    And I should see 1 annotations

  Scenario: Cannot unarchive a keyword with an archived sub-header
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    When I log in as the test user
    And I navigate to "/codingKeywords"
    When I click on a "header"
    And I click on a "sub-header"
    And I delete a sub-header
    Then I should see 1 archived sub-headers
    And I should see 1 archived keywords
    And I should not see the unarchive button

  @codingKeywords
  Scenario: Unarchiving headers that have been archived
    Given there is an annotation with codingKeyword header "Test Header", subHeader "Test Sub-Header" and key "Test Keyword1"
    When I log in as the test user
    And I navigate to "/codingKeywords"
    When I click on a "header"
    When I click on a "sub-header"
    Then I should see 1 keywords
    And I should see 0 archived keywords
    When I delete a header
    Then I should see 0 headers
    And I should see 1 archived headers
    And I should see 1 archived sub-headers
    And I should see 1 archived keywords
    When I unarchive a header
    Then I should see 1 headers
    And I should see 1 keywords
    When I navigate to "/documents"
    And I click the first document
    Then I should see 1 keywords
    And I should see 1 annotations
