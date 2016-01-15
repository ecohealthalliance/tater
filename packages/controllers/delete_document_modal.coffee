if Meteor.isClient

  Template.deleteDocumentModal.onCreated(->
    @ignoreClicks = false
  )

  Template.deleteDocumentModal.events
    'click #confirm-delete-document': (event, instance) ->
      unless instance.ignoreClicks
        instance.ignoreClicks = true
        documentId = event.target.attr('data-document-id')
        Meteor.call 'deleteDocument', documentId, (error) ->
          if error
            toastr.error("Server Error")
            instance.ignoreClicks = false
          else
            toastr.success("Success")


Meteor.methods
  deleteDocument: (documentId) ->
    check documentId, String
    user = Meteor.user()
    if not user then throw new Meteor.Error("Not authorized.")
    document = Documents.findOne(documentId)
    if not document then throw new Meteor.Error("Document does not exist.")
    group = Groups.findOne(document.groupId)
    if group?.viewableByUser(user)
      Documents.remove(documentId)
      Annotations.remove(documentId: documentId)
    else
      throw new Meteor.Error("Document is not accessible.")
