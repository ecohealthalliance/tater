if Meteor.isClient
  Template.deleteSubHeaderModal.events
    'click #confirm-delete-subheader': (event, instance) ->
      id = instance.data.subHeaderToDelete.get()?._id
      Meteor.call 'deleteSubHeader', id, (error) ->
        if error
          ErrorHelpers.handleError error
        else
          unless SubHeaders.findOne(id)
            instance.data.selectedCodes.set('subHeaderId', null)
          toastr.success 'Success'

Meteor.methods
  deleteSubHeader: (id) ->
    if not Meteor.user()?.admin
      throw new Meteor.Error 'unauthorized', 'You must be an admin to delete a subheader.'
    if not _.isString(id)
      throw new Meteor.Error 'invalid', 'You must specify a subheader id.'
    subheader = SubHeaders.findOne(id)
    codingKeyword = CodingKeywords.findOne(subHeaderId: id)
    if not subheader
      throw new Meteor.Error 'not-found', 'Subheader does not exist.'
    else if codingKeyword
      SubHeaders.update id,
        $set:
          archived: true
      CodingKeywords.update {subHeaderId: id},
        {$set:
          archived: true}
        {multi: true}
    else
      SubHeaders.remove(id)
