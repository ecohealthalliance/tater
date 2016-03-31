if Meteor.isClient
  Template.deleteSubHeaderModal.onCreated ->
    @archiving = new ReactiveVar false

  Template.deleteSubHeaderModal.helpers
    archiving: ->
      Template.instance().archiving.get()

  Template.deleteSubHeaderModal.events
    'click #confirm-delete-subheader': (event, instance) ->
      event.preventDefault()
      subHeaderId = instance.data.subHeaderToDelete.get()?._id
      instance.archiving.set true
      Meteor.call 'deleteSubHeader', subHeaderId, (error) ->
        if error
          ErrorHelpers.handleError error
          instance.archiving.set false
        else
          unless SubHeaders.findOne subHeaderId
            instance.data.selectedCodes.set 'subHeaderId', null
          toastr.success 'Success'
          instance.archiving.set false
          $('#confirm-delete-subheader-modal').modal 'hide'

Meteor.methods
  deleteSubHeader: (subHeaderId) ->
    if not Meteor.user()?.admin
      throw new Meteor.Error 'unauthorized', 'You must be an admin to delete a subheader.'
    if not _.isString subHeaderId
      throw new Meteor.Error 'invalid', 'You must specify a subheader id.'
    subHeader = SubHeaders.findOne subHeaderId
    if not subHeader
      throw new Meteor.Error 'not-found', 'Subheader does not exist.'
    else
      subHeader.archive()
