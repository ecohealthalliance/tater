Feature: BSVE

  @bsve
  Scenario: Failing automatic logging in using url parameter
    When there is a test user in the database
    And I log in as the test user
    Then I am logged in
    And I log out
    Then I log in by passing a secret access token via URL
    And I am not logged in

  @bsve
  Scenario: Automatic logging in using url parameters
    When there is a test user in the database with an access token
    And I am not logged in
    Then I log in by passing a secret access token via URL
    And I am logged in

  @bsve
  Scenario: Creating a new document in a single-user mode
    When there is a test user in the database with an access token
    Then I log in by passing a secret access token via URL
    And I click on the Add Document link in the header
    And I fill out the new document form with title "Test Document"
    And I should see a "Success" toast
    And I should see content "Test Document"
