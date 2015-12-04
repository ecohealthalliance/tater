if Meteor.isClient
  Template.deleteSubHeaderModal.events
    'click #confirm-delete-subheader': (event, instance) ->
      id = instance.data.subHeaderToDelete.get()?._id
      console.log id
      Meteor.call 'deleteSubHeader', id, (error) ->
        if error
          toastr.error("Error: #{error.message}")
          console.log error
        else
          toastr.success("Success")

if Meteor.isServer
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
