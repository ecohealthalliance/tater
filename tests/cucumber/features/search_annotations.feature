Feature: Search Annotations Page

  Background:
    Given there is a test user in the database
    And there is a test group in the database
    And there is a test document in the database
    And there is an annotation with codingKeyword header "Hdr1" and key "KeyC"

  @searchAnnotations
  Scenario: Viewing search annotations page
    When I log in as the test user
    And I visit the search annotations page
    Then I should not see the test annotation
    And I select the test group
    Then I should see the test annotation

  @searchAnnotations
  Scenario: Downloading a CSV
    When I log in as the test user
    And I visit the search annotations page
    And I select the test group
    And I click the Download CSV button
    Then I should see a link that downloads the generated CSV with header "Hdr1" and key "KeyC"