if Meteor.isClient
  Template.groupDetail.onCreated ->
    @subscribe('groupDetail', @data.groupId)

  Template.groupDetail.helpers
    group: ->
      Groups.findOne(@groupId)

    newDocumentUrl: ->
      "/groups/#{@groupId}/documents/new"

if Meteor.isServer
  Meteor.publish 'groupDetail', (id) ->
    Groups.find(id)
