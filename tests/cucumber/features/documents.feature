Feature: Documents

  Background:
    Given there is a test user in the database
    Given there is a test group in the database

  @documents
  Scenario: Viewing group documents as a non-admin
    When I log in as the test user
    When there are 2 documents in the "fakegroupid" group
    And I navigate to "/groups"
    And I create a user account for "non@admin.com"
    And I log out
    And I log in as "non@admin.com"
    And I click the documents header link
    Then I should be on the test group documents page

  @documents
  Scenario: Adding a group document as a non-admin
    When I log in as the test user
    And I navigate to "/groups"
    And I create a user account for "non@admin.com"
    And I log out
    And I log in as "non@admin.com"
    And I click on the Add Document link in the header
    And I fill out the new document form with title "Test Document"
    And I should see a "Success" toast
    Then I should see content "Test Document"

  @documents
  Scenario: Viewing all documents as an admin
    Given there is a group in the database with id "groupid1"
    And there is a group in the database with id "groupid2"
    Given there is a test document with title "First Doc" in group "groupid1"
    And there is a test document with title "Second Doc" in group "groupid2"
    When I log in as the test user
    And I click the documents header link
    Then I should see the "Documents" link highlighted in the header
    And I should see content "First Doc"
    And I should see content "Second Doc"

  @documents
  Scenario: Viewing one group's documents as an admin
    And there is a document with title "Test Doc" in the test group
    When I log in as the test user
    And I navigate to "/groups"
    And I click on the test group
    Then I should see content "Test Doc"

  @documents
  Scenario: Paginating group documents
    And there are 15 documents in the "fakegroupid" group
    And there are 2 documents in the "test2" group
    When I log in as the test user
    And I navigate to "/groups"
    And I click on the test group
    Then I should see 10 documents
    When I go to the next page of documents
    Then I should see 5 documents

  @documents
  Scenario: Adding a document as an admin
    When I log in as the test user
    And I click on the Add Document link in the header
    And I fill out the new document form with title "Test Document" and select the test group
    And I should see a "Success" toast
    And I should see content "Test Document"
    When I navigate to "/groups"
    And I click on the test group
    Then I should see content "Test Document"

  @documents
  Scenario: Uploading document file as an admin
    When I log in as the test user
    And I click on the Add Document link in the header
    And I should see content "Drop a document file here or click to upload from your computer"
    And I fill out the new document form with title "Test Document" and select the test group
    And I should see a "Success" toast
    And I should see content "Test Document"
    When I navigate to "/groups"
    And I click on the test group
    Then I should see content "Test Document"

  @documents
  Scenario: Deleting a document
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    When I navigate to "/groups"
    And I click on the test group
    Then I should see content "Test Document"
    When I click on the Delete Document button
    And I confirm the document deletion
    Then I should see a "Success" toast
    And I should not see content "Test Document"

  @documents
  Scenario: Adding a note to a document
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    And I navigate to the test document
    And I add the note "Good job" to the test document
    Then I should see content "Good job"

  @documents
  Scenario: Editing the note on a document
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    And I navigate to the test document
    And I add the note "Good job" to the test document
    Then I should see content "Good job"
    When I update the note to "Great job"
    Then I should see content "Great job"

  @documents
  Scenario: Mark a document as finished
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    And I navigate to the test document
    And I finish annotating a document with note
    Then I should see content "Finished"
    And I should see content "A note"

  @documents
  Scenario: Displaying crowdsource price
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    When I log in as the test user
    And I navigate to the test document
    And I click on the Crowdsource button
    Then I should see content "\$1.33"

  @documents
  Scenario: Visiting document page via mechanical turk
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    Then I stub out HIT request for the test document
    And I navigate to the test document using hitId
    Then I should see content "Test Document"
    And I should see content "Finish Annotating"

  @documents
  Scenario: Display Mechanical Turk instructions
    Given there is a test group in the database
    And there is a document with title "Test Document" in the test group
    Then I stub out HIT request for the test document
    And I preview the test document using hitId
    Then I should see content "Instructions"
    Then I should not see content "Sign In"

  @documents
  Scenario: Increasing and decreasing a document's annotation count
    And there is a coding keyword with header "Bur Bur" in the database
    When I log in as the test user

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

  @documents
  Scenario: Paginating documents page
    Given there are 15 documents in the database
    When I log in as the test user
    When I navigate to "/documents"
    Then I should see 10 documents
    When I go to the next page of documents
    Then I should see 5 documents

  @documents
  Scenario: Searching Documents
    Given there are 15 documents in the database
    When I log in as the test user
    When I navigate to "/documents"
    Then I should see 10 documents
    When I search for a document with the title of "document 12"
    Then I should see 1 document
    And I should see content "document 12"
