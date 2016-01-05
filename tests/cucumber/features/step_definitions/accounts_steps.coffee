do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a profile with ID 'fakeid' where "([^"]*)" is "([^"]*)"$/, (field, value)->
      @server.call('createProfile', field, value, 'fakeid')

    registerAccount = (browser, email) ->
      browser
        .url(url.resolve(process.env.ROOT_URL, '/'))
        .click('.sign-in')
        .waitForExist('.accounts-modal.modal.in')
        .click('#at-signUp')
        .waitForExist('#at-field-password_again')
        .setValue('#at-field-email', email)
        .setValue('#at-field-password', 'testuser')
        .setValue('#at-field-password_again', 'testuser')
        .submitForm('#at-field-email')
        .waitForExist('.sign-out')

    @Given /^I have registered an account$/, ->
      registerAccount(@browser, "test@user.com")

    @When "I register an account", ->
      registerAccount(@browser, "test@user.com")

    @When /^I register an account with email address "([^"]*)"$/, (email) ->
      registerAccount(@browser, email)

    @When 'I open the account modal', ->
      @browser
        .click('.sign-in')
        .waitForExist('.accounts-modal.modal.in')

    @When "I hide my email address from my profile", ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/profile/edit'))
        .waitForExist('#edit-profile-form')
        .click("#profile-email-hidden")
        .submitForm('#edit-profile-form')

    @When /^I fill out the profile edit form with fullName "([^"]*)"$/, (fullName) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/profile/edit'))
        .waitForExist('#edit-profile-form')
        .setValue('#profile-fullname', fullName)
        .setValue('#profile-jobtitle', 'User Tester')
        .setValue('#profile-bio', 'I am a test user')
        .submitForm('#profile-fullname')

    @When 'I view my public profile', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/profile/edit'))
        .waitForExist('#edit-profile-form')
        .click('.profile-detail-link')
        .waitForExist('.profile-detail')

    @Then /I am( not)? logged in/, (amNot) ->
      @browser
        .execute((->
          Meteor.userId()
        ), (err, ret) ->
          assert.ifError(err)
          if amNot
            assert.equal(ret.value, null, 'Authenticated')
          else
            assert(ret.value, 'Not authenticated')
        )

    @Then 'I am logged in as an admin user', ->
      @browser
        .execute((->
          Meteor.user().admin
        ), (err, ret) ->
          assert.ifError(err)
          assert.equal(ret.value, true, 'Not admin')
        )

    @When 'I create a user account for "$email"', (email) ->
      @browser
        .waitForVisible('.add-user')
        .click('.add-user')
        .pause(500)
        .waitForVisible('#add-user-modal')
        .waitForEnabled('#add-user-modal .user-email')
        .setValue('#add-user-modal .user-email', email)
        .setValue('#add-user-modal .user-name', 'test name')
        .setValue('#add-user-modal .user-password', 'testuser')
        .setValue('#add-user-modal .user-password-confirm', 'testuser')
        .submitForm('#add-user-modal .user-email')
        .waitForVisible('.toast-success')
        .pause(1500)

    @When 'I create an admin user account for "$email"', (email) ->
      @browser
        .waitForVisible('.add-admin')
        .click('.add-admin')
        .pause(500)
        .waitForVisible('#add-user-modal')
        .waitForEnabled('#add-user-modal .user-email')
        .setValue('#add-user-modal .user-email', email)
        .setValue('#add-user-modal .user-name', 'test name')
        .setValue('#add-user-modal .user-password', 'testuser')
        .setValue('#add-user-modal .user-password-confirm', 'testuser')
        .submitForm('#add-user-modal .user-email')
        .waitForVisible('.toast-success')
        .pause(1500)

    @When 'I log out', ->
      @browser
        .moveToObject('.dropdown-toggle')
        .waitForVisible('.sign-out')
        .click('.sign-out')
        .waitForExist('.sign-in')

    @When 'I log in as "$email"', (email) ->
      @browser
        .click('.sign-in')
        .waitForExist('.accounts-modal.modal.in')
        .setValue('#at-field-email', email)
        .setValue('#at-field-password', 'testuser')
        .submitForm('#at-field-email')
        .waitForExist('.sign-out')
        .click('.accept-eula')

    @When 'I click the remove user link', ->
      @browser
        .waitForVisible('.remove-user')
        .click('.remove-user')

    @When 'I confirm the account deletion', ->
      @browser
        .waitForVisible('.modal')
        .click('.confirm-remove-user')
        .waitForVisible('.modal-backdrop', 2000, true)

    @When 'I open the change password modal', ->
      @browser
        .moveToObject('nav .admin-settings')
        .waitForVisible('.dropdown-menu')
        .click('.dropdown-menu .change-password')
        .waitForExist('.accounts-modal.modal.in')

    @When 'I fill out the change password form', ->
      @browser
        .setValue('#at-field-current_password', 'password')
        .setValue('#at-field-password', 'newPassword')
        .setValue('#at-field-password_again', 'newPassword')
        .submitForm('#at-pwd-form')
        .pause(1000)

    @When 'I log in with my new password', ->
      @browser
        .click('.sign-in')
        .waitForExist('.accounts-modal.modal.in')
        .setValue('#at-field-email', 'test@example.com')
        .setValue('#at-field-password', 'newPassword')
        .submitForm('#at-field-email')
        .waitForExist('.sign-out')
