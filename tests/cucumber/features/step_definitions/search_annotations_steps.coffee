do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @Given 'there is a test annotation in the database', ->
      @server.call('createTestAnnotation', {})

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

    @When 'I click the Download CSV button', ->
      @browser
        .waitForExist('.download-csv')
        .click('.download-csv')

    @Then 'I should see a link that downloads the generated CSV', ->
      csvData = """documentId,userEmail,header,subHeader,keyword,text,flagged,createdAt\r
      fakedocumentid,,,,,T,false,"""
      @browser
        .waitForExist '#download-csv-modal .btn-primary'
        .getHTML '#download-csv-modal .btn-primary', (error, response) ->
          assert(response.search(encodeURIComponent(csvData)) >= 0)
