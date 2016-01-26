if Meteor.isClient
  Template.deleteSubHeaderModal.events
    'click #confirm-delete-subheader': (event, instance) ->
      id = instance.data.subHeaderToDelete.get()?._id
      if not gConnected then return toastr.error gConnectionErrorText
      Meteor.call 'deleteSubHeader', id, (error) ->
        if error
          toastr.error("Error: #{error.message}")
          console.log error
        else
          unless SubHeaders.findOne(id)
            instance.data.selectedCodes.set('subHeaderId', null)
          toastr.success("Success")

Meteor.methods
  deleteSubHeader: (id) ->
    if not Meteor.user()?.admin
      throw new Meteor.Error("You must be an admin to delete a subheader.")
    if not _.isString(id)
      throw new Meteor.Error("You must specify a subheader id.")
    subheader = SubHeaders.findOne(id)
    codingKeyword = CodingKeywords.findOne(subHeaderId: id)
    if not subheader
      throw new Meteor.Error("Subheader does not exist.")
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
