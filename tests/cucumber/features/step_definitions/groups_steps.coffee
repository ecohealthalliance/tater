do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given "there is a test group in the database", ->
      @server.call('createTestGroup')

    @When "I click the new group link", (callback) ->
      @browser
        .waitForExist('.groups-table')
        .click('.new-group-link', assert.ifError)
        .waitForExist('#new-group-form')
        .call(callback)

    @When /^I fill out the new group form with name "([^"]*)"$/, (name, callback) ->
      @browser
        .waitForExist('#new-group-form')
        .setValue('#group-name', name)
        .setValue('#group-description', 'This is an group.')
        .submitForm('#new-group-form', assert.ifError)
        .call(callback)

    @When /^I click on the group link$/, (callback) ->
      @browser
        .waitForExist('.group-list', assert.ifError)
        .click(".group-list a.list-link", assert.ifError)
        .waitForVisible('.documents', assert.ifError)
        .call(callback)

    @When /^I navigate to the test group page$/, (callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/groups/fakegroupid"))
        .waitForExist('.group-detail', assert.ifError)
        .call(callback)

    @Then /^I should be on the test group page$/, (callback) ->
      @browser
        .waitForVisible('.group-detail', assert.ifError)
        .getHTML '.group-detail h1', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
        .call(callback)
