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

    @When 'I type "$search" in the coding keyword search', (search) ->
      @browser
        .waitForVisible('.code-search')
        .setValue('.code-search', search)
        .waitForExist('.filteredCodes')

    @Then /^I should see (\d+) keywords$/, (number) ->
      @client
        .waitForExist('.level-3')
        .elements '.code-level-3', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @Then /^I should see (\d+) sub\-headers/, (number) ->
      @client
        .waitForExist('.level-2')
        .elements '.code-level-2', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @Then /^I should see (\d+) headers/, (number) ->
      @client
        .waitForExist('.level-1')
        .elements '.code-level-1', (error, elements) ->
          assert(elements.value.length == parseInt(number), "Expected #{elements.value.length} to equal #{number}")

    @When 'I delete a keyword', () ->
      @client
        .waitForVisible('.level-3')
        .click('.level-3 .fa-trash-o')
        .waitForVisible('#confirm-delete-keyword-modal')
        .click('#confirm-delete-keyword')
        .waitForVisible('.toast-message')
        # wait for modal to fade
        .waitForVisible('.modal-backdrop', 1000, false)

    @When 'I delete a sub-header', () ->
      @client
        .waitForVisible('.level-2')
        .click('.level-2 .fa-trash-o')
        .waitForVisible('#confirm-delete-subheader-modal')
        .click('#confirm-delete-subheader')
        # wait for modal to fade
        .waitForVisible('.modal-backdrop', 1000, false)

    @When 'I delete a header', () ->
      @client
        .waitForVisible('.level-1')
        .click('.level-1 .fa-trash-o')
        .waitForVisible('#confirm-delete-header-modal')
        .click('#confirm-delete-header')
        # wait for modal to fade
        .waitForVisible('.modal-backdrop', 1000, false)

    @When /^I add the "([^"]*)" "([^"]*)"$/, (level, code) ->
      if level == "header"
        @browser
          .waitForVisible(".add-#{level}")
          .click(".add-#{level}")
          .waitForVisible("input[name=#{level}]")
          .setValue("input[name=#{level}]", code)
          .click(".header-colors li:first-child")
          .submitForm("input[name=#{level}]")
      else
        @browser
          .waitForVisible(".add-#{level}")
          .click(".add-#{level}")
          .waitForVisible("input[name=#{level}]")
          .setValue("input[name=#{level}]", code)
          .submitForm("input[name=#{level}]")
