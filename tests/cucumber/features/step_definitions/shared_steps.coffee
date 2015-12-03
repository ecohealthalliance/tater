do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Before (callback) ->
      @server.call('reset')
      @client.url(url.resolve(process.env.ROOT_URL, '/'), callback)
      @client.execute( ->
        Meteor.logout()
      )

    _testUser = {email: 'test@example.com', password: 'password'}

    @Given /^there is a test user in the database/, ->
      @server.call('createTestUser', _testUser)

    @Given /^there is a group in the database/, ->
      @server.call('createTestGroup')

    @Given 'there is a group in the database with id "$id"', (id)->
      @server.call('createTestGroup', _id: id)

    @When "I log in as the test user", ->
      @client
        .url(url.resolve(process.env.ROOT_URL, '/'))
        .waitForExist('.sign-in')
        .click('.sign-in')
        .waitForVisible('.modal-content')
        .setValue('.accounts-modal #at-field-email', _testUser.email)
        .setValue('.accounts-modal #at-field-password', _testUser.password)
        .submitForm('.accounts-modal #at-field-email')
        .waitForExist('.sign-out')

    @When "I log in as the non-admin test group user", ->
      @client
        .url(url.resolve(process.env.ROOT_URL, '/'))
        .waitForExist('.sign-in')
        .click('.sign-in', assert.ifError)
        .setValue('#at-field-email', _nonAdminTestUser.email)
        .setValue('#at-field-password', _nonAdminTestUser.password)
        .submitForm('#at-field-email', assert.ifError)
        .waitForExist('.sign-out')

    @When /^I navigate to "([^"]*)"$/, (relativePath) ->
      @client
        .url(url.resolve(process.env.ROOT_URL, relativePath))

    @When 'I navigate to the admin page', ->
      @client
        .waitForExist('[href="/admin"]')
        .click('[href="/admin"]')

    @Then /^I should see the "([^"]*)" link highlighted in the header$/, (linkText, callback) ->
      @client
        .waitForExist('.navbar-nav')
        .getHTML('.navbar-nav .active', (error, response) ->
          match = response?.toString().match(linkText)
          assert.ok(match)
        ).call(callback)

    @Then /^I should( not)? see a "([^"]*)" toast$/, (noToast, message) ->
      @browser
        .waitForVisible('body *')
        # This causes a warning if no toast is visible
        .getHTML('.toast', (error, response) ->
          match = response?.toString().match(message)
          if noToast
            assert.ok(error or not match)
          else
            assert.ifError(error)
            assert.ok(match)
        )

    @Then 'I should see an error toast', ->
      @browser
        .waitForVisible '.toast-error'

    @Then /^I should( not)? see content "([^"]*)"$/, (shouldNot, text) ->
      @client
        .waitForVisible('body *')
        .getHTML 'body', (error, response) ->
          match = response.toString().match(text)
          if shouldNot
            assert.notOk(match)
          else
            assert.ok(match)
