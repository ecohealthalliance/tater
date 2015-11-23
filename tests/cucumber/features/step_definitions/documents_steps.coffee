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
      @server.call('createTestDocument', {title: title, groupId: 'fakegroupid', _id: 'fakedocid'})

    @Given /^there are (\d+) documents in the "([^"]*)" group$/, (number, groupId, callback) ->
      _(number).times (index)=>
        @server.call('createTestDocument', {title: 'document ' + index, groupId: groupId})
      callback()

    @Given /^there are (\d+) documents in the database$/, (number, callback) ->
      _(number).times (index)=>
        @server.call('createTestDocument', {title: 'document ' + index})
      callback()

    @When "I click the documents header link", ->
      @browser
        .waitForExist('.header-documents-link')
        .click('.header-documents-link')
        .waitForExist('.group-documents')

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

    @When "I navigate to the test document with an access code", ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents/fakedocid?generateCode=true"))
        .waitForExist('.document-container', assert.ifError)

    @When /^I click on the New Document link$/, (callback) ->
      @browser
        .waitForVisible('.new-document-link', assert.ifError)
        .click(".new-document-link", assert.ifError)
        .call(callback)

    @When /^I click on the Delete Document button$/, ->
      @browser
        .waitForVisible('.delete-document-button', assert.ifError)
        .click(".delete-document-button i", assert.ifError)

    @When /^I confirm the document deletion/, ->
      @browser
        .waitForExist('#confirm-delete-document-modal', assert.ifError)
        .click("#confirm-delete-document", assert.ifError)

    @When /^I fill out the new document form with title "([^"]*)"( and select the test group)?$/, (title, selectGroup) ->
      @browser
        .waitForExist('#new-document-form', assert.ifError)
        .setValue('#document-title', title)
        .setValue('#document-body', 'This is a document with 38 characters.')
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

    @Then "I should see an access code in a modal", ->
      @browser
        .getHTML '#completionCodeModal', (error, response) ->
          assert.notOk(error)
          assert.ok(response.toString().match("Code:"))

    @Then "I should see that \"$documentName\" is in the test group", (documentName) ->
      @browser
        .waitForVisible('.documents', assert.ifError)
        .getHTML '.document-list', (error, response) ->
          matchDocument = response.toString().match(documentName)
          matchGroup = response.toString().match("Test Group")
          assert.ok(matchDocument, "Document name not found")
          assert.ok(matchGroup, "Group not found")

    @Then /^I should see that document "([^"]*)" has( no)? annotations$/, (documentName, noAnnotations) ->
      @browser
        .waitForVisible('.document-list', assert.ifError)
        .getHTML '.document-list', (error, response) ->
          matchDocument = response.toString().match(documentName)
          #matchGroup = response.toString().match("Test Group")
          matchAnnotationMark = response.toString().match("fa-circle")
          assert.ok(matchDocument, "Document name not found")
          #assert.ok(matchGroup, "Group not found")
          if noAnnotations
            assert.notOk(matchAnnotationMark, "Annotations found")
          else
            assert.ok(matchAnnotationMark, "No annotations found")

    @When "I navigate to the document which has annotations", ->
      @browser
        .click(".document .list-link")
        .waitForVisible(".document-text", assert.ifError)

    @Then /^I should see (\d+) documents$/, (number) ->
      @client
        .waitForExist('.document-title', assert.ifError)
        .elements '.document-title', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @When /^I go to the next page of documents$/, ->
      @browser
        .waitForExist('.document-title', assert.ifError)
        .execute ->
          $("a:contains('>')").click()
