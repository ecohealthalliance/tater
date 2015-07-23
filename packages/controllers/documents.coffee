if Meteor.isClient
  Template.documents.onCreated ->
    @subscribe('documents', @data.groupId)

  Template.documents.helpers
    group: ->
      Groups.findOne(@groupId)

    documents: ->
      Documents.find({}, {groupId: @groupId})

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group.viewableByUserWithGroup(Meteor.user()?.group)


if Meteor.isServer
  Meteor.publish 'documents', (id) ->
    user = Meteor.users.findOne(@userId)
    group = Groups.findOne(id)

    if group.viewableByUserWithGroup(user?.group)
      [
        Groups.find(id)
        Groups.findOne(id).documents()
      ]
