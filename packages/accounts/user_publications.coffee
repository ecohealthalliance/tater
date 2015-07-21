if Meteor.isServer
  Meteor.publish "userInfo", () ->
    user = Meteor.users.findOne { _id: @userId }
    if user.admin
      Meteor.users.find {}, { fields: {admin: 1 , emails: 1, group: 1}}
    else if user
      Meteor.users.find {_id: user._id}, { fields: {admin: 1 , emails: 1, group: 1}}
    else
      @ready()
