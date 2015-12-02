do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @When "I click on the test user", ->
      @browser
        .waitForVisible('.users-table', assert.ifError)
        .click('.users-table .reactive-table tbody tr', assert.ifError)

    @Then "I should be on the user profile page", ->
      @browser
        .waitForVisible('.profile-detail', assert.ifError)
