do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    @Given "there are coding keywords in the database", ->
      @server.call('createCodingKeyword', {header: "Test Header"})
      @server.call('createCodingKeyword', {header: "Test Header", subHeader: "Test Sub-Header"})
      @server.call('createCodingKeyword', {header: "Test Header", subHeader: "Test Sub-Header", keyword: "Test Keyword"})

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

    @When /^I click the add "([^"]*)" button$/, (level) ->
      @browser
        .waitForVisible(".add-code[data-level='#{level}']")
        .click(".add-code[data-level='#{level}']")

    @When /^I add the "([^"]*)" "([^"]*)"$/, (level, code) ->
      @browser
        .waitForVisible("input[name='#{level}']")
        .setValue("input[name='#{level}']", code)
        .submitForm("input[name='#{level}']")
