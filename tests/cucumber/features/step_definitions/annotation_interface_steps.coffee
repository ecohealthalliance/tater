do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    _test_document = {title: "Test Document", body: "This is a doc for testing"}

    @Given 'there is a test document in the database', ->
      @server.call('createTestDocument', _test_document)

    @When 'I navigate to the annotation interface for the test document', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/documents"))
        .waitForVisible('.document-list', assert.ifError)
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
