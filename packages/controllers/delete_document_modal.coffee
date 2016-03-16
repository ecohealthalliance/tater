if Meteor.isClient

  noClickClassName = 'dont-click'

  Template.deleteDocumentModal.events
    'click #confirm-delete-document': (event, instance) ->
      $button = $ event.currentTarget
      unless $button.hasClass noClickClassName
        $button.addClass noClickClassName
        documentId = $button.attr('data-document-id')
        Meteor.call 'deleteDocument', documentId, (error, isClient) ->
          if error
            ErrorHelpers.handleError error
          else
            toastr.success('Success')
          if isClient
            $button.removeClass noClickClassName


Meteor.methods
  deleteDocument: (documentId) ->
    check documentId, String
    user = Meteor.user()
    if not user then throw new Meteor.Error 'unauthorized', 'You are not authorized to delete this document.'
    document = Documents.findOne(documentId)
    if not document then throw new Meteor.Error 'not-found', 'Document does not exist.'
    group = Groups.findOne(document.groupId)
    if group?.viewableByUser(user)
      document.remove()
      Annotations.remove(documentId: documentId)
    else
      throw new Meteor.Error 'unauthorized', 'Document is not accessible.'
    Meteor.isServer
