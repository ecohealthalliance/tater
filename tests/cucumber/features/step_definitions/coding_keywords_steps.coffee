do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    @Given /^there is a coding keyword with header "([^"]*)" in the database$/, (header) ->
      @server.call('createCodingKeyword', {header: header})

    @Given /^there is a coding keyword with header "([^"]*)" and sub-header "([^"]*)" in the database$/, (header, subHeader) ->
      @server.call('createCodingKeyword', {header: header, subHeader:subHeader})

    @Given /^there is a coding keyword with header "([^"]*)", sub-header "([^"]*)" and keyword "([^"]*)" in the database$/, (header, subHeader, keyword) ->
      @server.call('createCodingKeyword', {header: header, subHeader:subHeader, keyword:keyword})

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

    @When "I click the Add Code button", ->
      @browser
        .waitForVisible('[data-target="#add-keyword-modal"]')
        .click('[data-target="#add-keyword-modal"]')

    @When 'I add the keyword "$code"', (code) ->
      @browser
        .waitForVisible('input[name="keyword"]')
        .setValue('input[name="keyword"]', code)
        .submitForm('input[name="keyword"]')
