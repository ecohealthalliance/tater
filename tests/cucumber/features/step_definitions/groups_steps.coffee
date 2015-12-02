do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a( code-accessible)? test group in the database$/, (codeAccessible) ->
      @server.call('createTestGroup', codeAccessible: Boolean(codeAccessible))

    @When "I click the new group link", (callback) ->
      @browser
        .waitForExist('.groups-table')
        .click('.new-group-link')
        .waitForExist('#new-group-form')
        .call(callback)

    @When /^I fill out the new group form with name "([^"]*)"( and make it code-accessible)?$/, (name, codeAccessible) ->
      @browser
        .waitForExist('#new-group-form')
        .setValue('#group-name', name)
        .setValue('#group-description', 'This is an group.')
      if codeAccessible
        @browser.click('#group-code-accessible')
      @browser.submitForm('#new-group-form')


    @When "I click on the test group", ->
      @browser
        .waitForExist('.groups-table')
        .click('span.group-detail')

    @Then "I should be on the test group document page", ->
      @browser
        .waitForExist('.documents')

    @When /^I navigate to the test group page$/, (callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/groups/fakegroupid"))
        .waitForExist('.group-detail')
        .call(callback)

    @Then /^I should be on the test group page$/, (callback) ->
      @browser
        .waitForVisible('.group-detail', assert.ifError)
        .getHTML '.group-detail h1', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
        .call(callback)
