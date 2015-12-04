if Meteor.isClient
  Template.deleteDocumentModal.events
    'click #confirm-delete-document': (event) ->
      documentId = event.target.getAttribute('data-document-id')
      Meteor.call 'deleteDocument', documentId, (error) ->
        if error
          toastr.error("Server Error")
          console.log error
        else
          toastr.success("Success")

Meteor.methods
  deleteDocument: (documentId) ->
    document = Documents.findOne(documentId)
    if document
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      accessible = (user and group?.viewableByUser(user))
      if accessible
        Documents.remove({_id: documentId})
        Annotations.remove({documentId: documentId})
      else
        throw new Meteor.Error("Document is not accessible.")
    else
      throw new Meteor.Error("Document does not exist.")
