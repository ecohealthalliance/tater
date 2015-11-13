do ->
  'use strict'

  _ = require('underscore')
  $ = require('jquery')

  module.exports = ->

    url = require('url')

    @Given 'there is a test annotation in the database', ->
      @server.call('createTestAnnotation', {})

    @Given /^there are (\d+) test annotations in the database$/, (number, callback) ->
      _(number).times =>
        @server.call('createTestAnnotation', {})
      callback()

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

    @Then /^I should see (\d+) test annotations$/, (number) ->
      @client
        .waitForExist('.annotation-detail', assert.ifError)
        .elements '.annotation-detail', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @When 'I select the test group', ->
      @browser
        .click('.group-selector')

    @When /^I go to the next page of annotations$/, ->
      @browser
        .waitForExist('.annotation-detail', assert.ifError)
        .execute ->
          $("a:contains('>')").click()
