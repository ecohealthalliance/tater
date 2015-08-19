do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a test document with title "([^"]*)" in group "([^"]*)"$/, (title, groupId) ->
      @server.call('createTestDocument', {title: title, groupId: groupId})

    @Given "there is a test document with title \"$title\" in the database", (title) ->
      @server.call('createTestDocument', {title: title, groupId: 'fakegroupid', _id: 'fakedocid'})

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

    @When "I navigate to the test document with access code \"$code\"", (code) ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents/fakedocid?code=#{code}"))
        .waitForExist('.document-container', assert.ifError)

    @When /^I click on the New Document link$/, (callback) ->
      @browser
        .waitForVisible('.new-document-link', assert.ifError)
        .click(".new-document-link", assert.ifError)
        .call(callback)

    @When /^I fill out the new document form with title "([^"]*)"( and select the test group)?$/, (title, selectGroup) ->
      @browser
        .waitForExist('#new-document-form', assert.ifError)
        .setValue('#document-title', title)
        .setValue('#document-body', 'This is a document.')
      if selectGroup
        @browser.selectByVisibleText('#document-group-id', 'Test Group')
      @browser.submitForm('#new-document-form', assert.ifError)

    @Then /^I should be on the test group documents page$/, (callback) ->
      @browser
        .waitForVisible('.group-documents', assert.ifError)
        .getHTML '.group-documents .group-name', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)
        .call(callback)

    @Then /^I should be on the admin documents page$/, ->
      @browser
        .waitForVisible('.documents', assert.ifError)

    @When /^I click on the Add Document link in the header$/, ->
      @browser
        .waitForExist('.header-documents-link', assert.ifError)
        .click('.new-document', assert.ifError)
        .waitForExist('#new-document-form', assert.ifError)

    @When "I click on the Finished Annotating button", ->
      @browser
        .waitForExist('.finished-annotating', assert.ifError)
        .click('.finished-annotating', assert.ifError)
        .pause(10000)
        .waitForVisible('.modal.in', assert.ifError)

    @Then "I should see a completion code in a modal", ->
      @browser
        .getHTML '#completionCodeModal', (error, response) ->
          assert.notOk(error)
          assert.ok(response.toString().match("CompletionCode"))

    @Then "I should see that \"$documentName\" is in the test group", (documentName) ->
      @browser
        .waitForVisible('.documents', assert.ifError)
        .getHTML '.document-list', (error, response) ->
          matchDocument = response.toString().match(documentName)
          matchGroup = response.toString().match("Test Group")
          assert.ok(matchDocument, "Document name not found")
          assert.ok(matchGroup, "Group not found")
