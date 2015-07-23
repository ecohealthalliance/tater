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

    @When "I click the documents header link", (callback) ->
      @browser
        .waitForExist('.header-documents-link', assert.ifError)
        .click('.header-documents-link', assert.ifError)
        .waitForExist('.group-documents', assert.ifError)
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
        .waitForVisible('.groups-table', assert.ifError)
        .click(".groups-table a", assert.ifError)
        .waitForVisible('.group-detail', assert.ifError)
        .call(callback)

    @When /^I navigate to the test group page$/, (callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/groups/fakegroupid"))
        .waitForVisible('.group-detail', assert.ifError)
        .call(callback)

    @When /^I navigate to the test group documents page$/, (callback) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/groups/fakegroupid/documents"))
        .waitForVisible('.group-documents', assert.ifError)
        .call(callback)

    @When /^I click on the New Document link$/, (callback) ->
      @browser
        .waitForVisible('.new-document-link', assert.ifError)
        .click(".new-document-link", assert.ifError)
        .call(callback)

    @When /^I fill out the new document form with title "([^"]*)"$/, (title, callback) ->
      @browser
        .waitForExist('#new-document-form', assert.ifError)
        .setValue('#document-title', title)
        .setValue('#document-body', 'This is a document.')
        .submitForm('#new-document-form', assert.ifError)
        .call(callback)

    @Then /^I should be on the test group page$/, (callback) ->
      @browser
        .waitForVisible('.group-detail', assert.ifError)
        .getHTML '.group-detail h1', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
        .call(callback)

    @Then /^I should be on the test group documents page$/, (callback) ->
      @browser
        .waitForVisible('.group-documents', assert.ifError)
        .getHTML '.group-documents h1', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
        .call(callback)
