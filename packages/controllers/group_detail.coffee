if Meteor.isClient
  Template.groupDetail.onCreated ->
    @subscribe('groupDetail', @data.groupId)

  Template.groupDetail.helpers
    group: ->
      Groups.findOne(@groupId)

    groupDocumentsParams: ->
      _id: @groupId

if Meteor.isServer
  Meteor.publish 'groupDetail', (id) ->
    Groups.find(id)
