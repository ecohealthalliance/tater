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
      group = Groups.findOne({_id: @groupId})
      group.editableByUserWithGroup(Meteor.user().group)


if Meteor.isServer
  Meteor.publish 'groupDetail', (id) ->
    group = Groups.findOne(id)
    [
      Groups.find(id)
      group.documents()
    ]
