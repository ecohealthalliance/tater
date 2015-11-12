do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    @Given 'there is a coding keyword with header "$header" in the database', (header) ->
      @server.call('createCodingKeyword', {header: header})

    @When 'I type "$search" in the coding keyword search', (search) ->
      @browser
        .waitForVisible('.code-search')
        .setValue('.code-search', search)
        .waitForExist('.filteredCodes')

    @Then /^I should( not)? see coding keyword search results$/, (noResults) ->
      @browser
        .waitForExist('.filteredCodes')
        .getHTML '.filteredCodes', (error, response) ->
          if noResults
            assert.notOk(response.toString().match('selectable-code'), "Results found")
          else
            assert.ok(response.toString().match('selectable-code'), "No results found")

    @When "I click the Add Keyword button", ->
      @browser
        .waitForVisible('.add-keyword')
        .click('.add-keyword')

    @When 'I add the header "$header"', (header) ->
      @browser
        .waitForVisible('input[name="header"]')
        .setValue('input[name="header"]', header)
        .submitForm('input[name="header"]')
        .click('.close')

    @Then 'I should be able to find "$text" in the keyword table', (text) ->
      @browser
        .waitForVisible('.keyword-table .reactive-table-input')
        .setValue('.keyword-table .reactive-table-input', text)
        .pause(2000)
        .getHTML '.keyword-table tbody', (error, response) ->
          assert.ok(response.toString().match(text), "Text not found")
