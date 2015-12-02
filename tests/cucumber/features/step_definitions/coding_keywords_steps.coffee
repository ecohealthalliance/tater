do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    @Given /^there is a coding keyword with header "([^"]*)" in the database$/, (header) ->
      @server.call('createCodingKeyword', header, "Test Sub-Header", "Test Keyword", 1)

    @Given /^there is a coding keyword with header "([^"]*)" and sub\-header "([^"]*)" in the database$/, (header, subHeader) ->
      @server.call('createCodingKeyword', header, subHeader, "Test Keyword", 1)

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

    @Then /^I click the first document$/, () -> 
      @browser
        .waitForVisible('.document-list')
        .click('.document a')

    # @Then /^I should see (\d+) keywords$/, (number) ->
    #   @browser
    #     .waitForVisible('.selectable-code')
    #     .elements ".code-keyword", (error, elements) ->
    #       assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @When 'I type "$search" in the coding keyword search', (search) ->
      @browser
        .waitForVisible('.code-search')
        .setValue('.code-search', search)
        .waitForExist('.filteredCodes')

    @Then /^I should see (\d+) keywords$/, (number) ->
      @client
        .waitForExist('.level-3, .code-keywords', assert.ifError)
        .elements '.code-keyword, .code-level-3:not(.disabled)', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @Then /^I should see (\d+) annotations$/, (number) ->
      @client
        .waitForExist('.annotations', assert.ifError)
        .elements '.annotations li', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @Then /^I should see (\d+) archived keywords$/, (number) ->
      @client
        .waitForExist('.level-3', assert.ifError)
        .elements '.code-level-3.disabled', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @When 'I delete a keyword', () ->
      @client
        .waitForVisible('.level-3')
        .click('.fa-trash-o')
        .waitForVisible('#confirm-delete-keyword-modal')
        .click('#confirm-delete-keyword')
        .waitForVisible('.toast-message')

    @Then /^I should( not)? see coding keyword search results$/, (noResults) ->
      @browser
        .waitForExist('.annotations')
        .getHTML '.annotations', (error, response) ->
          console.log "response: ", response
          if noResults
            console.log "response: ", response
            assert.notOk(response.toString().match('data-annotation-id'), "Results found")
          else
            assert.ok(response.toString().match('data-annotation-id'), "No results found")

    @When "I click the Add Keyword button", ->
      @browser
        .waitForExist('.add-keyword')
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
