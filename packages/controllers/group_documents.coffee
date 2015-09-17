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
      $('#confirm-delete-document').attr("data-document-id", event.target.getAttribute("data-document-id"))

    'click #confirm-delete-document': (event) ->
      documentId = event.target.getAttribute('data-document-id')
      Meteor.call 'deleteDocument', documentId, (error) ->
        if error
          toastr.error("Server Error")
          console.log error
        else
          toastr.success("Success")

if Meteor.isServer
  Meteor.publish 'groupDocuments', (id) ->
    user = Meteor.users.findOne(@userId)
    group = Groups.findOne(id)

    if user and group?.viewableByUser(user)
      [
        Groups.find(id)
        Groups.findOne(id).documents()
      ]

  Meteor.methods
    deleteDocument: (documentId) ->
      document = Documents.findOne(documentId)
      if document
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        accessible = (user and group?.viewableByUser(user))
        if accessible
          Documents.remove({_id: documentId})
