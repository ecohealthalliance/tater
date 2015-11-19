do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    _test_document = {title: "Test Document", body: "This is a doc for testing", _id: "fakedocumentid"}

    @Given 'there is a test document in the database', ->
      @server.call('createTestDocument', _test_document)

    @When 'I navigate to the annotation interface for the test document', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents"))
        .waitForExist('.document-list', assert.ifError)
        .waitForVisible('.list-link', assert.ifError)
        .click('.list-link', assert.ifError)
        .waitForVisible('.document-detail-container', assert.ifError)

    @Then 'I should see the test document title', ->
      @browser
        .getText('.document-title').then (title) ->
          assert.equal(title, _test_document.title)

    @Then 'I should see the test document body', ->
      @browser
        .getText('.document-body').then (body) ->
          assert(body =~ _test_document.body)

    @When 'I highlight some document text', ->
      @browser
        .waitForVisible('.document-text', assert.ifError)
        .moveToObject('.document-text')
        .doDoubleClick()

    @When 'I click on a coding keyword', ->
      @browser
        .click('.code-list .coding')

    @Then /^I should( not)? see an annotation in the annotations list$/, (noAnnotations) ->
      @browser
        .getHTML '.annotations', (error, response) ->
          if noAnnotations
            assert(!response.match("<li"))
            assert(response.match("no-results"))
          else
            assert(!response.match("no-results"))
            assert(response.match("<li"))

    @When 'I remove all annotations', ->
      @browser
        .waitForExist('.delete-annotation', assert.ifError)
        .moveToObject('.annotations > li')
        .waitForVisible('.delete-annotation', assert.ifError)
        .click('.delete-annotation')
