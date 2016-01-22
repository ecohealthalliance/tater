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

    @When 'I add my credit card information', ->
      @browser
        .setValue('[data-stripe=cardNumber]', '4242424242424242')
        .setValue('[data-stripe=expirationMonth]', '08')
        .setValue('[data-stripe=expirationYear]', '30')
        .setValue('[data-stripe=cvc]', '123')

    @When 'I submit the tenant registration form', ->
      @browser
        .submitForm('#tenant-registration')
