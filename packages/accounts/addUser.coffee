Meteor.methods

  addGroupUser: (email, password, admin, groupId) ->

    Accounts.createUser
      email : email
      password : password
      admin: admin
      group: groupId
