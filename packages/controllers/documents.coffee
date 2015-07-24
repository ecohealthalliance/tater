if Meteor.isClient
  Template.documents.onCreated ->
    @subscribe('documents')

  Template.documents.helpers
    documents: ->
      Documents.find({}, {groupId: @groupId})

if Meteor.isServer
  Meteor.publish 'documents', ->
    user = Meteor.users.findOne({_id: @userId, admin: true})
    if user
      Documents.find()
