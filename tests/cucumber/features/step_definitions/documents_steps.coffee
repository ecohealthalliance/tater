do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a test document with title "([^"]*)" in group "([^"]*)"$/, (title, groupId) ->
      @server.call('createTestDocument', {title: title, groupId: groupId})

    @Given /^there is a document with title "([^"]*)" in the test group$/, (title) ->
      @server.call('createTestDocument', {title: title, groupId: 'fakegroupid'})

    @When "I click the documents header link", (callback) ->
      @browser
        .waitForExist('.header-documents-link', assert.ifError)
        .click('.header-documents-link', assert.ifError)
        .waitForExist('.group-documents', assert.ifError)
        .call(callback)

    @When "I click on the group documents link", (callback) ->
      @browser
        .waitForExist('.group-documents-link', assert.ifError)
        .click('.group-documents-link', assert.ifError)
        .waitForExist('.documents', assert.ifError)
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

    @Then /^I should be on the test group documents page$/, (callback) ->
      @browser
        .waitForVisible('.group-documents', assert.ifError)
        .getHTML '.group-documents h1', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
        .call(callback)
