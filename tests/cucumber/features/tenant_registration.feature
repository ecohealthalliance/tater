Feature: Tenant Registration

  @tenantRegistration
  Scenario: Registering as a new Tenant
    When I navigate to "/register"
    And I fill out the tenant registration form
    Then I should see content "Thank you for registering."
