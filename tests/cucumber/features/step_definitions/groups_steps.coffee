do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a( code-accessible)? test group in the database$/, (codeAccessible) ->
      @server.call('createTestGroup', codeAccessible: Boolean(codeAccessible))

    @When "I click the new group link", ->
      @browser
        .waitForExist('.new-group-link')
        .click('.new-group-link')
        .waitForExist('#new-group-form')

    @When /^I fill out the new group form with name "([^"]*)"( and make it code-accessible)?$/, (name, codeAccessible) ->
      brChain = @browser
        .waitForExist('#new-group-form')
        .setValue('#group-name', name)
        .setValue('#group-description', 'This is an group.')
      if codeAccessible
        brChain = brChain.click('#group-code-accessible')
      brChain = brChain.submitForm('#new-group-form')

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
