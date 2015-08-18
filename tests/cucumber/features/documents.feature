Feature: Documents

  Background:
    Given there is a test user in the database

  @documents
  Scenario: Viewing group documents as a non-admin
    Given there is a test group in the database
    When I log in as the test user
    And I navigate to the admin page
    And I create a user account for "non@admin.com"
    And I log out
    And I log in as "non@admin.com"
    And I click the documents header link
    Then I should be on the test group documents page

  @documents
  Scenario: Adding a group document as a non-admin
    Given there is a test group in the database
    When I log in as the test user
    And I navigate to the admin page
    And I create a user account for "non@admin.com"
    And I log out
    And I log in as "non@admin.com"
    And I click on the Add Document link in the header
    And I fill out the new document form with title "Test Document"
    Then I should be on the test group documents page
    And I should see content "Test Document"
    And I should see a "Success" toast

  @documents
  Scenario: Viewing all documents as an admin
    Given there is a test document with title "First Doc" in group "groupid1"
    And there is a test document with title "Second Doc" in group "groupid2"
    When I log in as the test user
    And I click the documents header link
    Then I should see content "First Doc"
    And I should see content "Second Doc"

  @documents
  Scenario: Viewing one group's documents as an admin
    Given there is a test group in the database
    And there is a document with title "Test Doc" in the test group
    When I log in as the test user
    And I navigate to "/admin"
    And I click on the group link
    Then I should see content "Test Doc"

  @documents
  Scenario: Adding a document as an admin
    Given there is a test group in the database
    When I navigate to "/"
    When I log in as the test user
    And I click on the Add Document link in the header
    And I fill out the new document form with title "Test Document" and select the test group
    Then I should be on the admin documents page
    And I should see that "Test Document" is in the test group
    And I should see a "Success" toast

  @documents
  Scenario: Viewing a documents as a with an access code
    Given there is a test document in the database
    When I navigate to the test document with access code "fakecode"
    Then I should see content "Test Document"
