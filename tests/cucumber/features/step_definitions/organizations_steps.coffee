do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @When "I click the new group link", (callback) ->
      @browser
        .waitForExist('.groups-table')
        .click('.new-group-link', assert.ifError)
        .waitForExist('#new-group-form')
        .call(callback)

    @When /^I fill out the new group form with name "([^"]*)"$/, (name, callback) ->
      @browser
        .waitForExist('#new-group-form')
        .setValue('#group-name', name)
        .setValue('#group-description', 'This is an group.')
        .submitForm('#new-group-form', assert.ifError)
        .call(callback)

    @When /^I click on the group link$/, (callback) ->
      @browser
        .waitForVisible('.groups-table', assert.ifError)
        .click(".groups-table a", assert.ifError)
        .waitForVisible('.group-detail', assert.ifError)
        .call(callback)

    @Then /^I should be on the "([^"]*)" detail page$/, (name, callback) ->
      @browser
        .waitForVisible('.group-detail', assert.ifError)
        .call(callback)
