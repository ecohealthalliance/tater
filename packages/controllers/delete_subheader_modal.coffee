if Meteor.isClient
  Template.deleteSubHeaderModal.onCreated ->
    @archiving = new ReactiveVar false

  Template.deleteSubHeaderModal.helpers
    archiving: ->
      Template.instance().archiving.get()

  Template.deleteSubHeaderModal.events
    'click #confirm-delete-subheader': (event, instance) ->
      id = instance.data.subHeaderToDelete.get()?._id
      instance.archiving.set true
      Meteor.call 'deleteSubHeader', id, (error) ->
        if error
          ErrorHelpers.handleError error
        else
          unless SubHeaders.findOne(id)
            instance.data.selectedCodes.set('subHeaderId', null)
          toastr.success 'Success'
          instance.archiving.set false
          $('#confirm-delete-subheader-modal').modal('hide')

Meteor.methods
  deleteSubHeader: (id) ->
    if not Meteor.user()?.admin
      throw new Meteor.Error 'unauthorized', 'You must be an admin to delete a subheader.'
    if not _.isString(id)
      throw new Meteor.Error 'invalid', 'You must specify a subheader id.'
    subHeader = SubHeaders.findOne(id)
    if not subheader
      throw new Meteor.Error 'not-found', 'Subheader does not exist.'
    else
      subHeader.archive()
