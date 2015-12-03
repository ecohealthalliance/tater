do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a test group in the database$/, ->
      @server.call('createTestGroup')

    @When "I click the new group link", ->
      @browser
        .waitForExist('.new-group-link')
        .click('.new-group-link')
        .waitForExist('#new-group-form')

    @When /^I fill out the new group form with name "([^"]*)"$/, (name) ->
      @browser
        .waitForExist('#new-group-form')
        .setValue('#group-name', name)
        .setValue('#group-description', 'This is an group.')
        .submitForm('#new-group-form')

    @When "I click on the test group", ->
      @browser
        .waitForExist('.groups-table')
        .click('span.group-detail')

    @Then "I should be on the test group document page", ->
      @browser
        .waitForVisible('.group-documents')
        .getHTML '.group-documents .group-name', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)

    @When /^I click on the group link$/, ->
      @browser
        .waitForExist('.group-list')
        .click(".group-list a.list-link")
        .waitForVisible('.documents')

    @When /^I navigate to the test group page$/, ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/groups/fakegroupid"))
        .waitForExist('.group-detail')

    @Then /^I should be on the test group page$/, ->
      @browser
        .waitForVisible('.group-detail')
        .getHTML '.group-detail h1', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
