do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a profile with ID 'fakeid' where "([^"]*)" is "([^"]*)"$/, (field, value)->
      @server.call('createProfile', field, value, 'fakeid')

    registerAccount = (browser, email, callback) ->
      browser
        .url(url.resolve(process.env.ROOT_URL, '/'))
        .click('.sign-in', assert.ifError)
        .waitForExist('.accounts-modal.modal.in')
        .click('#at-signUp')
        .waitForExist('#at-field-password_again')
        .setValue('#at-field-email', email)
        .setValue('#at-field-password', 'testuser')
        .setValue('#at-field-password_again', 'testuser')
        .submitForm('#at-field-email', assert.ifError)
        .waitForExist('.sign-out')
        .call(callback)

    @Given /^I have registered an account$/, (callback) ->
      registerAccount(@browser, "test@user.com", callback)

    @When "I register an account", (callback) ->
      registerAccount(@browser, "test@user.com", callback)

    @When /^I register an account with email address "([^"]*)"$/, (email, callback) ->
      registerAccount(@browser, email, callback)

    @When 'I open the account modal', (callback) ->
      @browser
        .click('.sign-in', assert.ifError)
        .waitForExist('.accounts-modal.modal.in')
        .call(callback)

    @When "I hide my email address from my profile", (callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/profile/edit'))
        .waitForExist('#profile-edit-form')
        .click("#profile-email-hidden")
        .submitForm('#profile-fullname', assert.ifError)
        .call(callback)

    @When /^I fill out the profile edit form with fullName "([^"]*)"$/, (fullName, callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/profile/edit'))
        .waitForExist('#profile-edit-form')
        .setValue('#profile-fullname', fullName)
        .setValue('#profile-jobtitle', 'User Tester')
        .setValue('#profile-bio', 'I am a test user')
        .click("#profile-email-hidden")
        .submitForm('#profile-fullname', assert.ifError)
        .call(callback)

    @When /^I view my public profile$/, (callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/profile/edit'))
        .waitForExist('#profile-edit-form')
        .click('.profile-detail-link')
        .waitForExist('.profile-detail')
        .call(callback)

    @Then /I am( not)? logged in/, (amNot, callback) ->
      @browser
        .execute((->
          Meteor.userId()
        ), (err, ret) ->
          assert.ifError(err)
          if amNot
            assert.equal(ret.value, null, 'Authenticated')
          else
            assert(ret.value, 'Not authenticated')
        ).call(callback)

    @Then 'I am logged in as an admin user', (callback) ->
      @browser
        .execute((->
          Meteor.user().admin
        ), (err, ret) ->
          assert.ifError(err)
          assert.equal(ret.value, true, 'Not admin')
        ).call(callback)

    @When 'I create a user account for "$email"', (email) ->
      @browser
        .waitForVisible('.add-user')
        .click('.add-user')
        .pause(500)
        .waitForVisible('#add-group-user-modal', assert.ifError)
        .waitForEnabled('#add-group-user-modal .user-email', assert.ifError)
        .setValue('#add-group-user-modal .user-email', email)
        .setValue('#add-group-user-modal .user-password', 'testuser')
        .setValue('#add-group-user-modal .user-password-confirm', 'testuser')
        .submitForm('#add-group-user-modal .user-email', assert.ifError)
        .pause(1000)
        .waitForVisible('.toast-success', assert.ifError)

    @When 'I create an admin user account for "$email"', (email) ->
      @browser
        .waitForVisible('.add-admin')
        .click('.add-admin')
        .pause(500)
        .waitForVisible('#add-admin-modal', assert.ifError)
        .waitForEnabled('#add-admin-modal .user-email', assert.ifError)
        .setValue('#add-admin-modal .user-email', email)
        .setValue('#add-admin-modal .user-password', 'testuser')
        .setValue('#add-admin-modal .user-password-confirm', 'testuser')
        .submitForm('#add-admin-modal .user-email', assert.ifError)
        .pause(1000)
        .waitForVisible('.toast-success', assert.ifError)

    @When 'I log out', (callback) ->
      @browser
        .click('.dropdown-toggle')
        .waitForVisible('.sign-out')
        .click('.sign-out')
        .waitForExist('.sign-in')
        .call(callback)

    @When 'I log in as "$email"', (email, callback) ->
      @browser
        .click('.sign-in', assert.ifError)
        .waitForExist('.accounts-modal.modal.in')
        .setValue('#at-field-email', email)
        .setValue('#at-field-password', 'testuser')
        .submitForm('#at-field-email', assert.ifError)
        .waitForExist('.sign-out', assert.ifError)
        .call(callback)

    @When /^I click the remove user link$/, (callback) ->
      @browser
        .waitForVisible('.remove-user', assert.ifError)
        .click(".remove-user", assert.ifError)
        .call(callback)

    @When /^I confirm the account deletion$/, (callback) ->
      @browser
        .waitForVisible('.modal', assert.ifError)
        .click('.confirm-remove-user', assert.ifError)
        .call(callback)

    @When 'I open the change password modal', (callback) ->
      @browser
        .click('nav .admin-settings', assert.ifError)
        .waitForExist('nav .admin-settings .dropdown-menu')
        .click('.dropdown-menu .change-password', assert.ifError)
        .waitForExist('.accounts-modal.modal.in')
        .call(callback)

    @When 'I fill out the change password form', (callback) ->
      @browser
        .setValue('#at-field-current_password', 'password')
        .setValue('#at-field-password', 'newPassword')
        .setValue('#at-field-password_again', 'newPassword')
        .submitForm('#at-pwd-form', assert.ifError)
        .pause(1000)
        .call(callback)

    @When 'I log in with my new password', (callback) ->
      @browser
        .click('.sign-in', assert.ifError)
        .waitForExist('.accounts-modal.modal.in')
        .setValue('#at-field-email', 'test@example.com')
        .setValue('#at-field-password', 'newPassword')
        .submitForm('#at-field-email', assert.ifError)
        .waitForExist('.sign-out', assert.ifError)
        .call(callback)
