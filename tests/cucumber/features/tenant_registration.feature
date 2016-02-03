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
