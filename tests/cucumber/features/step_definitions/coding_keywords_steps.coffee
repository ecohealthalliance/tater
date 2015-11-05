do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

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
