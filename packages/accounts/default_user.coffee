Meteor.methods
  createDefaultUser: (email, password) ->
    if (!Meteor.users.find().count())
      Accounts.createUser(email: email, password: password, admin: true)
