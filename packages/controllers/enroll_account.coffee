if Meteor.isClient
  AccountsTemplates.removeField('password');
  AccountsTemplates.addFields([
    {
      _id: 'password'
      type: 'password'
      required: true
      minLength: 8
      re: /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}/
      errStr: 'Password must contain at least 1 number, 1 lowercase letter and 1 uppercase letter'
      template: 'passwordField'
    },
    {
      _id: 'password_again'
      type: 'password'
      displayName: 'Confirm Password'
      required: true
      template: 'passwordFieldConfirm'
    }
  ])
  Template.enrollAccount.onCreated ->
    AccountsTemplates.setState('changePwd')
    AccountsTemplates.paramToken = @data.token
    @autorun ->
      if Meteor.user()
        go 'splashPage'

if Meteor.isServer
  Meteor.startup ->
    Accounts.emailTemplates.from = "\"Tater Accounts\" <no-reply@tater.io>"
    Accounts.urls.enrollAccount = (token) ->
      "#{Meteor.absoluteUrl()}enroll-account/#{token}"
