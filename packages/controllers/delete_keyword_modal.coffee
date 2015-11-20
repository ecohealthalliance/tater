if Meteor.isClient
  Template.deleteKeywordModal.events
    'click #confirm-delete-keyword': (event) ->
      keywordId = event.target.getAttribute('data-keyword-id')
      Meteor.call 'deleteKeyword', keywordId, (error) ->
        if error
          toastr.error(error.error)
          console.log error
        else
          toastr.success("Success")

if Meteor.isServer
  Meteor.methods
    deleteKeyword: (keywordId) ->
      codingKeyword = CodingKeywords.findOne(keywordId)
      timesUsed = Annotations.find
        codeId: keywordId
      .count()
      if !codingKeyword
        throw new Meteor.Error("Keyword does not exist.")
      else if timesUsed > 0
        throw new Meteor.Error("Keyword is in use - it cannot be deleted.")
      else
        CodingKeywords.remove codingKeyword._id
        # CodingKeywords.update codingKeyword._id,
        #   $set:
        #     deleted: true

        # debugger
        # user = Meteor.users.findOne(@userId)
        # accessible = (user and codingKeyword?.viewableByUser(user))
        # if accessible
        #   CodingKeywords.update codingKeyword._id,
        #     deleted: true
        # else
        #   throw new Meteor.Error("Keyword is not accessible.")

