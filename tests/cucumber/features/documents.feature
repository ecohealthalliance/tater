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
    Then I should see content "Test Document"
    And I should see a "Success" toast

  @documents
  Scenario: Viewing all documents as an admin
    Given there is a test document with title "First Doc" in group "groupid1"
    And there is a test document with title "Second Doc" in group "groupid2"
    When I log in as the test user
    And I click the documents header link
    Then I should see the "Documents" link highlighted in the header
    And I should see content "First Doc"
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
  Scenario: Paginating group documents
    Given there is a test group in the database
    And there are 15 documents in the "fakegroupid" group
    And there are 2 documents in the "test2" group
    When I log in as the test user
    And I navigate to "/admin"
    And I click on the group link
    Then I should see 10 documents
    When I go to the next page of documents
    Then I should see 5 documents

  @documents
  Scenario: Adding a document as an admin
    Given there is a test group in the database
    When I navigate to "/"
    When I log in as the test user
    And I click on the Add Document link in the header
    And I fill out the new document form with title "Test Document" and select the test group
    And I should see content "Test Document"
    And I should see a "Success" toast
    When I navigate to "/admin"
    And I click on the group link
    Then I should see content "Test Document"

  @documents
  Scenario: Viewing a document with an access code
    Given there is a code-accessible test group in the database
    And there is a document with title "Test Document" in the test group
    When I navigate to the test document with an access code
    Then I should see content "Test Document"
    When I click on the Finished Annotating button
    Then I should see an access code in a modal

  @documents
  Scenario: Deleting a document
    Given there is a code-accessible test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    When I navigate to "/admin"
    And I click on the group link
    Then I should see content "Test Document"
    When I click on the Delete Document button
    And I confirm the document deletion
    Then I should see a "Success" toast
    And I should not see content "Test Document"

  @documents
  Scenario: Increasing and decreasing a document's annotation count
    Given there is a test group in the database
    When I log in as the test user

    And I navigate to "/editCodingKeywords"
    When I click the Add Keyword button
    And I add the header "Bur Bur"
    Then I should be able to find "Bur Bur" in the keyword table

    And I click on the Add Document link in the header
    And I fill out the new document form with title "Annotation Test Doc" and select the test group

    When I highlight some document text
    And I click on a coding keyword

    When I click the documents header link
    Then I should see that document "Annotation Test Doc" has annotations

    When I navigate to the document which has annotations
    And I remove all annotations
    When I click the documents header link
    Then I should see that document "Annotation Test Doc" has no annotations

  Scenario: Paginating documents page
    Given there are 15 documents in the database
    When I log in as the test user
    When I navigate to "/documents"
    Then I should see 10 documents
    When I go to the next page of documents
    Then I should see 5 documents
