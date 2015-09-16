if Meteor.isClient
  Template.documents.onCreated ->
    @subscribe('documentsAndGroups')

  Template.documents.helpers

    documents: ->
      Documents.find().map((doc)->
        doc.groupName = Groups.findOne(doc.groupId)?.name
        doc
      )

if Meteor.isServer
  Meteor.publish 'documentsAndGroups', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      [
        Documents.find(),
        Groups.find({}, {fields: {name: 1}})
      ]
    else if user
      [
        Documents.find({groupId: user.group}),
        Groups.find({_id: user.group}, {fields: {name: 1}})
      ]
