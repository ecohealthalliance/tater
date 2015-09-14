if Meteor.isClient
  Template.groupDocuments.onCreated ->
    @subscribe('groupDocuments', @data.groupId)

  Template.groupDocuments.helpers
    group: ->
      Groups.findOne(@groupId)

    documents: ->
      Documents.find({}, {groupId: @groupId})

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group.viewableByUser(Meteor.user())

  Template.groupDocuments.events
    'click .delete-document-button': (event) ->
      if confirm("Delete this document?")
        Meteor.call 'deleteDocument', event.target.getAttribute('data-document-id'), ->
          toastr.success("Success")

if Meteor.isServer
  Meteor.publish 'groupDocuments', (id) ->
    user = Meteor.users.findOne(@userId)
    group = Groups.findOne(id)

    if user and group.viewableByUser(user)
      [
        Groups.find(id)
        Groups.findOne(id).documents()
      ]

  Meteor.methods
    deleteDocument: (documentId) ->
      Documents.remove({_id: documentId})
