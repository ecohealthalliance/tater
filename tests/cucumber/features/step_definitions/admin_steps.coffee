do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @When "I click on the test user", ->
      @browser
        .waitForVisible('.users-table', assert.ifError)
        .click('.users-table .reactive-table tr', assert.ifError)

    @Then "I should be on the user profile page", ->
      @browser
        .waitForExist('.profile-detail', assert.ifError)
