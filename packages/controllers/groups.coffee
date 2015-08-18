if Meteor.isClient
  Template.groups.onCreated ->
    @subscribe('groups')
    @selectedGroup = new ReactiveVar()

  Template.groups.helpers
    groups: ->
      if Meteor.userId()
        Groups.find({}, sort: name: 1)
    group: ->
      Template.instance().selectedGroup

  Template.groups.events
    'click .add-user': (event, template) ->
      template.selectedGroup.set(@)

if Meteor.isServer
  Meteor.publish 'groups', ->
    user = Meteor.users.findOne { _id: @userId }
    if user?.admin
      Groups.find {}
    else if user
      Groups.find {_id: user.group }
    else
      @ready()
