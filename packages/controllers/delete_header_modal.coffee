if Meteor.isClient
  Template.deleteHeaderModal.events
    'click #confirm-delete-header': (event, instance) ->
      id = instance.data.headerToDelete.get()?._id
      Meteor.call 'deleteHeader', id, (error) ->
        if error
          ErrorHelpers.handleError error
        else
          # only reset headerId if it was deleted and not archived
          unless Headers.findOne(id)
            instance.data.selectedCodes.set('headerId', null)
          toastr.success 'Success'

if Meteor.isServer
  Meteor.methods
    deleteHeader: (id) ->
      if not Meteor.user()?.admin
        throw new Meteor.Error 'unauthorized', 'You must be an admin to delete a header.'
      if not _.isString(id)
        throw new Meteor.Error 'invalid', 'You must specify a header id.'
      header = Headers.findOne(id)
      subHeaders = SubHeaders.find(headerId: id).fetch()
      if not header
        throw new Meteor.Error 'not-found', 'Header does not exist.'
      else if subHeaders.length > 0
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
      else
        Headers.remove(id)
