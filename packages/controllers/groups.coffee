if Meteor.isClient
  Template.groups.onCreated ->
    @subscribe('groups')

  Template.groups.helpers
    groups: ->
      if Meteor.userId()
        Groups.find({createdById: Meteor.userId()})

if Meteor.isServer
  Meteor.publish 'currentUserGroups', ->
    Groups.find({createdById: this.userId})
