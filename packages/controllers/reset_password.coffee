if Meteor.isClient
  Template.resetPassword.onCreated ->
    AccountsTemplates.paramToken = @data.token

if Meteor.isServer
  Meteor.startup ->
    Accounts.emailTemplates.resetPassword.text = (user, url) ->
      url = url.replace('#/', '')
      "Click this link to reset your password: " + url
