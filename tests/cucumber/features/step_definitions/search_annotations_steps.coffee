do ->
  'use strict'

  _ = require('underscore')
  $ = require('jquery')

  module.exports = ->

    url = require('url')

    @Given /^there is an annotation with codingKeyword header "([^"]*)", subHeader "([^"]*)" and key "([^"]*)"$/, (header, subHeader, keyword) ->
      that = @
      @server
        .call('createCodingKeyword', header, subHeader, keyword, 1)
        .then (codeId) ->
          that.server.call('createTestAnnotation', {codeId: codeId})
          codeId

    @Given 'there is a test annotation in the database', ->
      @server.call('createTestAnnotation', {})

    @Given /^there are (\d+) test annotations in the database$/, (number) ->
      Promise.all _.range(number).map =>
        @server.call('createTestAnnotation', {})

    @When 'I visit the search annotations page', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, "/annotations"))
        .waitForExist('.annotations-list-container')

    @Then /^I should( not)? see the test annotation$/, (noAnnotations) ->
      @browser
        .getHTML '.annotations-list-container', (error, response) ->
          if noAnnotations
            assert(!response.match('div class=\"annotation-detail\"'))
          else
            assert(response.match('div class=\"annotation-detail\"'))

    @Then /^I should see (\d+) test annotations$/, (number) ->
      @client
        .waitForExist('.annotation-detail')
        .elements '.annotation-detail', (error, elements) ->
          assert(elements.value.length == parseInt(number),
            "Expected #{elements.value.length} to equal #{number}")

    @When 'I select the test group', ->
      @browser
        .click('.group-selector')
        .waitForExist('.annotation-detail')

    @When 'I expand the test group', ->
      @browser
        .click('.down')
        .waitForExist('.group-docs')

    @Then /^I should see (\d+) greyed out document$/, (number) ->
      @client
        .elements '.doc-title.disabled', (error, elements) ->
          assert(elements.value.length == parseInt(number),
            "Expected #{elements.value.length} to equal #{number}")

    @When 'I click the Download CSV button', ->
      @browser
        .waitForExist('.download-csv')
        .click('.download-csv')

    @Then /^I should see a link that downloads the generated CSV with header "([^"]*)", subHeader "([^"]*)" and key "([^"]*)"$/, (header, subHeader, keyword) ->
      csvData = """\uFEFFdocumentId,userEmail,header,subHeader,keyword,text,flagged,createdAt\r
      fakedocumentid,,#{header},#{subHeader},#{keyword},T,false,"""
      @browser
        .waitForExist '#download-csv-modal .btn-primary'
        .getHTML '#download-csv-modal .btn-primary', (error, response) ->
          assert(response.search(encodeURIComponent(csvData)) >= 0,
            "Expected #{response} to match #{encodeURIComponent(csvData)}")

    @When 'I go to the next page of annotations', ->
      @browser
        .waitForVisible('ul.pagination li:nth-last-child(2):not(.disabled)')
        .execute -> # Can't just use .click() because it may not be visible
          $('ul.pagination li:nth-last-child(2):not(.disabled) a').click()
        .pause(2000) # Give Meteor a moment to update the list
