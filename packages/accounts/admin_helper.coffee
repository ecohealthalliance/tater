if Meteor.isClient
  UI.registerHelper 'isAdmin', () ->
    Meteor.user()?.admin
