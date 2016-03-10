if Meteor.isClient
  Template.deleteKeywordModal.helpers
    keywordId: ->
      Template.instance().data.keywordToDelete?._id

    keywordLabel: ->
      Template.instance().data.keywordToDelete?.label

  Template.deleteKeywordModal.events
    'click #confirm-delete-keyword': (event) ->
      keywordId = event.target.getAttribute('data-keyword-id')
      Meteor.call 'deleteKeyword', keywordId, (error) ->
        if error
          ErrorHelpers.handleError error
        else
          toastr.success("Success")


Meteor.methods
  deleteKeyword: (keywordId) ->
    user = Meteor.user()
    if user?.admin
      codingKeyword = CodingKeywords.findOne keywordId
      if not codingKeyword
        throw new Meteor.Error 'not-found', 'Keyword does not exist.'
      else
        codingKeyword.archive()
    else
      throw new Meteor.Error 'unauthorized', 'Only admins can delete keywords.'
