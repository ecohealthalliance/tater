Feature: Splash Page

  Background:
    Given there is a test user in the database
    And there is a test group in the database

  @splashPage
  Scenario: Viewing Recent Documents
    Given there is a test document with title "First Doc" in group "Test Group"
    And there is a test document with title "Second Doc" in group "Test Group"
    When I log in as the test user
    And I navigate to "/"
    Then I should see content "First Doc" as "second" element in the Recent Documents list
    Then I should see content "Second Doc" as "first" element in the Recent Documents list
