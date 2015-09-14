if Meteor.isServer
  Meteor.startup ->
    if (!Meteor.users.find().count())
      Accounts.createUser(email: 'admin@example.com', password: 'admin', admin: true)
