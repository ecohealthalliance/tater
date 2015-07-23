if Meteor.isClient
  Template.groupDetail.onCreated ->
    @subscribe('groupDetail', @data.groupId)

  Template.groupDetail.helpers
    group: ->
      Groups.findOne(@groupId)

    documents: ->
      Documents.find({}, {groupId: @groupId})

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group.editableByUserWithGroup(Meteor.user().group)


if Meteor.isServer
  Meteor.publish 'groupDetail', (id) ->
    [
      Groups.find(id)
      Groups.findOne(id).documents()
    ]
