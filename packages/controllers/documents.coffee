if Meteor.isClient
  Template.documents.onCreated ->
    @subscribe('documents')

  Template.documents.helpers

    documents: ->
      Documents.find({}, {groupId: @groupId})

if Meteor.isServer
  Meteor.publish 'documents', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      Documents.find()
    else if user
      Documents.find { groupId: user.group }

