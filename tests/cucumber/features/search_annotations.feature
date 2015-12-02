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
    Then I should see the "Search Annotations" link highlighted in the header
    And I should not see the test annotation
    When I select the test group
    Then I should see the test annotation

  @searchAnnotations
  Scenario: Downloading a CSV
    Given there is an annotation with codingKeyword header "Hdr1", subHeader "SubHeader" and key "KeyC"
    When I log in as the test user
    And I visit the search annotations page
    And I select the test group
    And I click the Download CSV button
    Then I should see a link that downloads the generated CSV with header "Hdr1", subHeader "SubHeader" and key "KeyC"

  @searchAnnotations
  Scenario: Paginating search annotations page
    Given there are 15 test annotations in the database
    When I log in as the test user
    And I visit the search annotations page
    And I select the test group
    Then I should see 10 test annotations

    When I go to the next page of annotations
    Then I should see 5 test annotations
