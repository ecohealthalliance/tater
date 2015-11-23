do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    @Given /^there is a coding keyword with header "([^"]*)" in the database$/, (header) ->
      @server.call('createCodingKeyword', {header: header})

    @Given /^there is a coding keyword with header "([^"]*)" and sub-header "([^"]*)" in the database$/, (header, subHeader) ->
      @server.call('createCodingKeyword', {header: header, subHeader:subHeader})

    @Given /^there is a coding keyword with header "([^"]*)", sub-header "([^"]*)" and keyword "([^"]*)" in the database$/, (header, subHeader, keyword) ->
      @server.call('createCodingKeyword', header, subHeader, keyword, 1)

    @When /^I click on a "([^"]*)"$/, (level) ->
      if level == 'header'
        @browser
          .waitForVisible('.level-1')
          .click('.code-level-1')
      else
        @browser
          .waitForVisible('.level-2')
          .click('.code-level-2')

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
