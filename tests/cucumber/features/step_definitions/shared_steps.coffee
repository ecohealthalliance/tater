do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Before (callback) ->
      @server.call('reset')
      @client.url(url.resolve(process.env.ROOT_URL, '/'), callback)

    _testUser = {email: 'test@example.com', password: 'password'}

    @Given /^there is a test user in the database/, ->
      @server.call('createTestUser', _testUser)

    @Given /^there is a group in the database/, ->
      @server.call('createTestGroup')

    @Given /^the user is not logged in/, ->
      @client.execute( ->
          Meteor.logout()
        );

    @When "I log in as the test user", (callback) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, '/'))
        .waitForExist('.sign-in')
        .click('.sign-in', assert.ifError)
        .setValue('.accounts-modal #at-field-email', _testUser.email)
        .setValue('.accounts-modal #at-field-password', _testUser.password)
        .submitForm('.accounts-modal #at-field-email', assert.ifError)
        .waitForExist('.sign-out')
        .call(callback)

    @When "I log in as the non-admin test group user", (callback) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, '/'))
        .waitForExist('.sign-in')
        .click('.sign-in', assert.ifError)
        .setValue('#at-field-email', _nonAdminTestUser.email)
        .setValue('#at-field-password', _nonAdminTestUser.password)
        .submitForm('#at-field-email', assert.ifError)
        .waitForExist('.sign-out')
        .call(callback)

    @When /^I navigate to "([^"]*)"$/, (relativePath, callback) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, relativePath))
        .call(callback)

    @When 'I navigate to the admin page', (callback) ->
      @client
        .waitForExist('[href="/admin"]')
        .click('[href="/admin"]')
        .call(callback)

    @Then /^I should see the "([^"]*)" link highlighted in the header$/, (linkText, callback) ->
      @client
        .waitForExist('.navbar-nav')
        .getHTML('.navbar-nav .active', (error, response) ->
          match = response?.toString().match(linkText)
          assert.ok(match)
        ).call(callback)

    @Then /^I should( not)? see a "([^"]*)" toast$/, (noToast, message, callback) ->
      @browser
        .waitForVisible('body *')
        .getHTML('.toast', (error, response) ->
          match = response?.toString().match(message)
          if noToast
            assert.ok(error or not match)
          else
            assert.ifError(error)
            assert.ok(match)
        ).call(callback)

    @Then /^I should( not)? see content "([^"]*)"$/, (shouldNot, text, callback) ->
      @client
        .waitForVisible('body *')
        .getHTML 'body', (error, response) ->
          match = response.toString().match(text)
          if shouldNot
            assert.notOk(match)
          else
            assert.ok(match)
        .call(callback)
