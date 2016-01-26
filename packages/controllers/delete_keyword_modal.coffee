if Meteor.isClient
  Template.deleteKeywordModal.helpers
    keywordId: ->
      Template.instance().data.keywordToDelete?._id

    keywordLabel: ->
      Template.instance().data.keywordToDelete?.label

  Template.deleteKeywordModal.events
    'click #confirm-delete-keyword': (event) ->
      if not gConnected then return toastr.error gConnectionErrorText
      keywordId = event.target.getAttribute('data-keyword-id')
      Meteor.call 'deleteKeyword', keywordId, (error) ->
        if error
          toastr.error(error.message)
        else
          toastr.success("Success")


Meteor.methods
  deleteKeyword: (keywordId) ->
    user = Meteor.user()
    if user?.admin
      codingKeyword = CodingKeywords.findOne(keywordId)
      timesUsed = Annotations.find
        codeId: keywordId
      .count()
      if !codingKeyword
        throw new Meteor.Error("Keyword does not exist.")
      else if timesUsed > 0
        CodingKeywords.update codingKeyword._id,
          $set:
            archived: true
      else
        CodingKeywords.remove codingKeyword._id
    else
      throw new Meteor.Error("Only admins can delete keywords.")
