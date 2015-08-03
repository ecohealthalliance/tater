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

    @When 'I fill out the new account form', (callback) ->
      @browser
        .click('#at-signUp')
        .waitForExist('#at-field-password_again')
        .setValue('#at-field-email', 'test@user.com')
        .setValue('#at-field-password', 'testuser')
        .setValue('#at-field-password_again', 'testuser')
        .submitForm('#at-field-email', assert.ifError)
        .waitForExist('.sign-out')
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

    @When 'I create an user account for "$email"', (email, callback) ->
      @browser
        .waitForVisible('#user-email')
        .setValue('#user-email', email)
        .setValue('#user-password', 'testuser')
        .setValue('#user-password-confirm', 'testuser')
        .submitForm('#user-email', assert.ifError)
        # This pause is necessairy, I think the waitForVisible function
        # can't cope with elements that fade in and out.
        .pause(500)
        .waitForVisible('.toast-success', assert.ifError)
        .call(callback)

    @When 'I create an admin user account for "$email"', (email, callback) ->
      @browser
        .waitForVisible('#user-email')
        .setValue('#user-email', email)
        .setValue('#user-password', 'testuser')
        .setValue('#user-password-confirm', 'testuser')
        .click('#user-admin')
        .submitForm('#user-email', assert.ifError)
        .pause(500)
        .waitForVisible('.toast-success', assert.ifError)
        .call(callback)

    @When 'I log out', (callback) ->
      @browser
        .click('.dropdown-toggle')
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

    @When /^I confirm the deletion$/, (callback) ->
      @browser
        .waitForVisible('.modal', assert.ifError)
        .click('.confirm-remove-user', assert.ifError)
        .call(callback)
