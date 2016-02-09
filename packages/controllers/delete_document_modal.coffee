if Meteor.isClient

  noClickClassName = 'dont-click'

  Template.deleteDocumentModal.events
    'click #confirm-delete-document': (event, instance) ->
      $button = $ event.currentTarget
      unless $button.hasClass noClickClassName
        $button.addClass noClickClassName
        documentId = $button.attr('data-document-id')
        Meteor.call 'deleteDocument', documentId, (error, isServer) ->
          if error
            toastr.error('Server Error')
          else
            toastr.success('Success')
          if isServer
            $button.removeClass noClickClassName


Meteor.methods
  deleteDocument: (documentId) ->
    check documentId, String
    user = Meteor.user()
    if not user then throw new Meteor.Error('Not authorized.')
    document = Documents.findOne(documentId)
    if not document then throw new Meteor.Error('Document does not exist.')
    group = Groups.findOne(document.groupId)
    if group?.viewableByUser(user)
      Documents.remove(documentId)
      Annotations.remove(documentId: documentId)
    else
      throw new Meteor.Error('Document is not accessible.')
    Meteor.isServer
