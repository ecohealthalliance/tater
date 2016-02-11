if Meteor.isClient

  Template.passwordField.helpers
    loggingIn: ->
      AccountsTemplates.getState() is 'signIn'
