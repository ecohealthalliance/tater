do ->
  'use strict'

  _ = require('underscore')

  module.exports = ->

    url = require('url')

    @When 'I fill out the tenant registration form', ->
      @browser
        .waitForVisible('#tenant-registration')
        .setValue('.full-name', 'Test Name')
        .setValue('.email', 'testUser@test.com')
        .setValue('.org-name', 'Organization Name')
        .setValue('.tenant-name', 'test')
        .submitForm('#tenant-registration')
