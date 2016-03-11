if Meteor.isClient
  Template.deleteKeywordModal.onCreated ->
    @archiving = new ReactiveVar false

  Template.deleteKeywordModal.helpers
    keywordId: ->
      Template.instance().data.keywordToDelete?._id

    keywordLabel: ->
      Template.instance().data.keywordToDelete?.label

    archiving: ->
      Template.instance().archiving.get()

  Template.deleteKeywordModal.events
    'click #confirm-delete-keyword': (event, instance) ->
      instance.archiving.set true
      keywordId = event.target.getAttribute 'data-keyword-id'
      Meteor.call 'deleteKeyword', keywordId, (error) ->
        if error
          ErrorHelpers.handleError error
          instance.archiving.set false
        else
          toastr.success("Success")
          instance.archiving.set false
          $('#confirm-delete-keyword-modal').modal 'hide'


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
