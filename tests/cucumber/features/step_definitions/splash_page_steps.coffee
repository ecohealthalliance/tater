do ->
  'use strict'

  _ = require('underscore')
  $ = require('jquery')

  module.exports = ->

    url = require('url')

    @Then /^I should see content "([^"]*)" as "([^"]*)" element in the Recent Documents list$/, (docTitle, position, callback) ->
      @browser
        .waitForExist('.recent-documents')
        .execute ((position) ->
          if position == "first"
            $('.recent-documents li:first-child').text()
          else
            $('.recent-documents li:nth-child(2)').text()
        ), position
        .then (response) ->
          match = response.value.toString().match(docTitle)
          assert.ok(match)
        .call(callback)
