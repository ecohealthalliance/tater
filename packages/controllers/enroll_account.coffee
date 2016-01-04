if Meteor.isClient
  Template.enrollAccount.onCreated ->
    AccountsTemplates.paramToken = @data.token
    @autorun ->
      if Meteor.user()
        go 'splashPage'

if Meteor.isServer
  Meteor.startup ->
    Accounts.emailTemplates.from = "\"Tater Accounts\" <no-reply@tater.io>"
    Accounts.urls.enrollAccount = (token) ->
      "#{Meteor.absoluteUrl()}enroll-account/#{token}"
