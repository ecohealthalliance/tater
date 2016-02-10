if Meteor.isClient
  AccountsTemplates.removeField('password');
  AccountsTemplates.addField({
    _id: 'password',
    type: 'password',
    placeholder: {
        signUp: "At least eight characters"
    },
    required: true,
    minLength: 8,
    re: /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}/,
    errStr: 'At least 1 digit, 1 lowercase and 1 uppercase'
  });
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
