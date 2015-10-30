do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    _test_annotation = {title: "Test Document", body: "This is a doc for testing"}

    @Given 'there is a test annotation in the database', ->
      @server.call('createTestAnnotation', _test_annotation)

    @When 'I visit the search annotations page', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/annotations"))
        .waitForExist('.annotations-list-container', assert.ifError)

    @Then /^I should( not)? see the test annotation$/, (noAnnotations) ->
      @browser
        .getHTML '.annotations-list-container', (error, response) ->
          if noAnnotations
            assert(!response.match('li class=\"annotation-detail\"'))
          else
            assert(response.match('li class=\"annotation-detail\"'))

    @When 'I select the test group', ->
      @browser
        .click('.group-selector')
