if Meteor.isClient
  Template.groups.onCreated ->
    @subscribe('groups')

  Template.groups.helpers
    groups: ->
      if Meteor.userId()
        Groups.find({createdById: Meteor.userId()})

if Meteor.isServer
  Meteor.publish 'groups', ->
    user = Meteor.users.findOne { _id: @userId }
    if user?.admin
      console.log 'is admin'
      Groups.find {}
    else if user
      Groups.find {_id: user.group }
    else
      @ready()