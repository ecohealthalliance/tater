do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given 'there is a test annotation in the database', ->
      _codeId = "";
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
      for [1..25]
        _codeId += possible.charAt(Math.floor(Math.random() * possible.length));

      @server.call('createCodingKeyword', {_id: _codeId, header:'Human', subHeader: 'Train', color: 1})
      _test_annotation = {title: "Test Document", body: "This is a doc for testing", codeId: _codeId}
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
