do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given /^there is a test document with title "([^"]*)" in group "([^"]*)"$/, (title, groupId) ->
      @server.call 'createTestDocumentFixture', title: title, groupId: groupId

    @Given 'there is a test document with title "$title" in the database', (title) ->
      @server.call 'createTestDocumentFixture', title: title, groupId: 'fakegroupid', _id: 'fakeDocumentId'

    @Given /^there is a document with title "([^"]*)" in the test group$/, (title) ->
      @server.call 'createTestDocumentFixture', title: title, groupId: 'fakegroupid', _id: 'fakeDocumentId'

    @Given /^there are (\d+) documents in the "([^"]*)" group$/, (number, groupId, callback) ->
      _(number).times (index)=>
        @server.call 'createTestDocumentFixture', title: 'document ' + index, groupId: groupId
      callback()

    @Given /^there are (\d+) documents in the database$/, (number, callback) ->
      _(number).times (index)=>
        @server.call 'createTestDocumentFixture', title: 'document ' + index
      callback()

    @When "I click the documents header link", ->
      @browser
        .waitForExist('.header-documents-link')
        .click('.header-documents-link')
        .waitForExist('.document-list')

    @When "I click on the group documents link", ->
      @browser
        .waitForExist('.group-documents-link')
        .click('.group-documents-link')
        .waitForExist('.documents')

    @When 'I navigate to the test group documents page', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/groups/fakegroupid/documents"))
        .waitForVisible('.group-documents')

    @When 'I navigate to the test document', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents/fakeDocumentId"))
        .waitForExist('.document-container')

    @When "I stub out HIT request for the test document", ->
      @server.call('setHIDIdFixture', 'fakeDocumentId')

    @When 'I preview the test document using hitId', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents/fakeDocumentId?assignmentId=ASSIGNMENT_ID_NOT_AVAILABLE&hitId=fakeHITId&noHeader=1"))

    @When 'I navigate to the test document using hitId', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents/fakeDocumentId?assignmentId=X&hitId=fakeHITId&noHeader=1"))
        .waitForExist('.document-container')

    @When 'I click on the New Document link', ->
      @browser
        .waitForVisible('.new-document-link')
        .click(".new-document-link")

    @When 'I click on the Delete Document button', ->
      @browser
        .waitForVisible('.doc-options')
        .moveToObject('.doc-options')
        .waitForVisible('.doc-options-buttons')
        .click(".delete-document-button")

    @When 'I confirm the document deletion', ->
      @browser
        .waitForVisible('#confirm-delete-document-modal')
        .click("#confirm-delete-document")

    @When /^I fill out the new document form with title "([^"]*)"( and select the test group)?$/, (title, selectGroup) ->
      brChain = @browser
        .waitForExist('#new-document-form')
        .setValue('#document-title', title)
        .setValue('#document-body', 'This is a document with 38 characters.')
      if selectGroup
        brChain = brChain.selectByVisibleText('#document-group-id', 'Test Group')
      brChain
        .submitForm('#new-document-form')
        .waitForVisible('.document-detail-container')

    @Then 'I should be on the test group documents page', ->
      @browser
        .waitForVisible('.group-documents')
        .getHTML '.group-documents .group-name', (error, response) ->
          match = response.toString().match("Test Group")
          assert.ok(match)

    @Then 'I should be on the admin documents page', ->
      @browser
        .waitForVisible('.documents')

    @When 'I click on the Add Document link in the header', ->
      @browser
        .waitForExist('.header-documents-link')
        .click('.new-document')
        .waitForExist('#new-document-form')

    @When "I click on the Finished Annotating button", ->
      @browser
        .waitForExist('.finished-annotating')
        .click('.finished-annotating')
        .pause 1000
        .waitForVisible('.modal.in')

    @Then "I should see an access token in a modal", ->
      @browser
        .getHTML '#completionCodeModal', (error, response) ->
          assert.notOk(error)
          assert.ok(response.toString().match("Code:"))

    @Then 'I should see that "$documentName" is in the test group', (documentName) ->
      @browser
        .waitForVisible('.documents')
        .getHTML '.document-list', (error, response) ->
          matchDocument = response.toString().match(documentName)
          matchGroup = response.toString().match("Test Group")
          assert.ok(matchDocument, "Document name not found")
          assert.ok(matchGroup, "Group not found")

    @Then /^I should see that document "([^"]*)" has( no)? annotations$/, (documentName, noAnnotations) ->
      @browser
        .waitForVisible('.document-list')
        .getHTML '.document-list', (error, response) ->
          matchDocument = response.toString().match(documentName)
          matchAnnotationMark = response.toString().match("fa-adjust")
          assert.ok(matchDocument, "Document name not found")
          if noAnnotations
            assert.notOk(matchAnnotationMark, "Annotations found")
          else
            assert.ok(matchAnnotationMark, "No annotations found")

    @When 'I navigate to the document which has annotations', ->
      @browser
        .click(".document .list-link")
        .waitForVisible(".document-text")

    @Then /^I should see (\d+) documents?$/, (number) ->
      @client
        .waitForExist('.document-title')
        .elements '.document-title', (error, elements) ->
          elemCount = elements.value.length
          assert(elemCount == +number, "Expected #{elemCount} to equal #{number}")

    @When 'I go to the next page of documents', ->
      @browser
        .waitForExist('.document-title')
        .execute ->
          $("li.active").next("li").children("a").click()
        .pause(2000) # wait for the page to change

    @When /^I search for a document with the title of "([^"]*)"$/, (documentName) ->
      @browser
        .waitForExist('.document-list')
        .setValue('.document-search', documentName)
        .pause(2000)
        .getHTML '.document-list', (error, response) ->
          if error instanceof Error
            console.error error.message
          match = response.toString().match(documentName)
          assert.ok(match)

    @When "I click on the Crowdsource button", ->
      @browser
        .waitForVisible('a.crowdsource-btn')
        .click('a.crowdsource-btn')

    @When "I submit the Crowdsource Annotation form", ->
      @browser
        .waitForVisible('#create-mturk-job')
        .click('#create-mturk-job')

    @When "I submit the Crowdsource Annotation form", ->
      @browser
        .waitForVisible('#create-mturk-job')
        .click('#create-mturk-job')

    @When /^I add the note "([^"]*)" to the test document$/, (note) ->
      @browser
        .waitForExist('.add-note')
        .click('.add-note')
        .waitForVisible('#document-note-modal')
        .setValue('#note', note)
        .submitForm('#document-note')

    @When /^I update the note to "([^"]*)"$/, (note) ->
      @browser
        .waitForExist('.edit-note')
        .click('.edit-note')
        .waitForVisible('#document-note-modal')
        .setValue('#note', note)
        .submitForm('#document-note')

    @When "I finish annotating a document with note", ->
      @browser
        .waitForExist('a.finished-btn')
        .click('a.finished-btn')
        .waitForVisible('#finish-annotation-modal')
        .click('.toggle-add-note')
        .waitForVisible('.form-control')
        .setValue('#finished-note', 'A note')
        .submitForm('#finish-annotation')
