Feature: Tenant Registration

  @tenantRegistration
  Scenario: Registering as a new Tenant requires credit card info
    When I navigate to "/register"
    And I fill out the tenant registration form
    And I submit the tenant registration form
    Then I should not see content "Thank you for registering."
    When I add my credit card information
    And I submit the tenant registration form
    Then I should see content "Thank you for registering."

  @tenantRegistration
  Scenario: Registering with incorrect zip code fails
    When I navigate to "/register"
    And I fill out the tenant registration form
    And I submit the tenant registration form
    When I add my credit card information with incorrect zip code
    And I submit the tenant registration form
    Then I should not see content "Thank you for registering."

    When I add my credit card information
    And I submit the tenant registration form
    Then I should see content "Thank you for registering."

  @tenantRegistration
  Scenario: Seed the database with initial tenant record
    When I seed the database with the test tenant record via URL
    Then I should see a "The seed has been planted" toast
    When I log in as the test user
    Then I am logged in
    And I am logged in as an admin user

  @tenantRegistration
  Scenario: Fail to seed the database with initial tenant record the second time
    When I seed the database with the test tenant record via URL
    Then I should see a "The seed has been planted" toast
    When I log in as the test user
    Then I am logged in
    And I am logged in as an admin user
    Then I log out
    And I seed the database with the test tenant record via URL
    Then I should not see a "The seed has been planted" toast
