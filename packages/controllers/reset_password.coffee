if Meteor.isClient
  Template.resetPassword.onCreated ->
    AccountsTemplates.paramToken = @data.token
    @autorun ->
      if Meteor.user()
        go 'splashPage'

if Meteor.isServer
  Meteor.startup ->
    Accounts.emailTemplates.from = "\"Tater Accounts\" <no-reply@tater.io>"
    Accounts.urls.resetPassword = (token) ->
      "#{Meteor.absoluteUrl()}reset-password/#{token}"
