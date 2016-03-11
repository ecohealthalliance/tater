if Meteor.isClient
  Template.deleteHeaderModal.onCreated ->
    @archiving = new ReactiveVar false

  Template.deleteHeaderModal.helpers
    archiving: ->
      Template.instance().archiving.get()

  Template.deleteHeaderModal.events
    'click #confirm-delete-header': (event, instance) ->
      headerId = instance.data.headerToDelete.get()?._id
      instance.archiving.set true
      Meteor.call 'deleteHeader', headerId, (error) ->
        if error
          ErrorHelpers.handleError error
          instance.archiving.set false
        else
          # only reset headerId if it was deleted and not archived
          unless Headers.findOne headerId
            instance.data.selectedCodes.set 'headerId', null
          toastr.success 'Success'
          instance.archiving.set false
          $('#confirm-delete-header-modal').modal 'hide'

if Meteor.isServer
  Meteor.methods
    deleteHeader: (headerId) ->
      if not Meteor.user()?.admin
        throw new Meteor.Error 'unauthorized', 'You must be an admin to delete a header.'
      if not _.isString headerId
        throw new Meteor.Error 'invalid', 'You must specify a header id.'
      header = Headers.findOne headerId
      if not header
        throw new Meteor.Error 'not-found', 'Header does not exist.'
      else
        header.archive()
