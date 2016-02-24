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

    @When /^I add my credit card information( with incorrect zip code)?$/, (incorrectZipCode) ->
      if incorrectZipCode
        cardNumber = "4000000000000036"
      else
        cardNumber = "4242424242424242"
      @browser
        .setValue('[data-stripe=cardNumber]', cardNumber)
        .selectByValue('[data-stripe=expirationMonth]', '08')
        .selectByValue('[data-stripe=expirationYear]', '2020')
        .setValue('[data-stripe=cvc]', '123')
        .setValue('[data-stripe=addressZip]', '10003')

    @When 'I submit the tenant registration form', ->
      @browser
        .submitForm('#tenant-registration')

    @When 'I seed the database with the test tenant record via URL', ->
      @browser
        .url(url.resolve(process.env.ROOT_URL, '/seed?fullName=Test User&emailAddress=test@example.com&orgName=Test Org&stripeCustomerId=nothing'))
        .pause(100)
        .then =>
          @server
            .call 'setUserAccountPasswordFixture',
              email: 'test@example.com'
              password: 'password'
