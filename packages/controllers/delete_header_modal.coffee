if Meteor.isClient
  Template.deleteHeaderModal.events
    'click #confirm-delete-header': (event, instance) ->
      id = instance.data.headerToDelete.get()?._id
      Meteor.call 'deleteHeader', id, (error) ->
        if error
          toastr.error("Error: #{error.message}")
          console.log error
        else
          toastr.success("Success")

if Meteor.isServer
  Meteor.methods
    deleteHeader: (id) ->
      if not Meteor.user()?.admin
        throw new Meteor.Error("You must be an admin to delete a header.")
      if not _.isString(id)
        throw new Meteor.Error("You must specify a header id.")
      header = Headers.findOne(id)
      subHeaders = SubHeaders.find(headerId: id).fetch()
      if not header
        throw new Meteor.Error("Header does not exist.")
      else if subHeaders
        Headers.update id,
          $set:
            archived: true        
        SubHeaders.update {headerId: id},
          {$set:
            archived: true}
          {multi: true}
        CodingKeywords.update {subHeaderId: {$in: _.pluck(subHeaders, "_id")}},
          {$set:
            archived: true}
          {multi: true}        
        # throw new Meteor.Error("Headers with subheaders cannot be deleted.")
      else
        Headers.remove(id)
