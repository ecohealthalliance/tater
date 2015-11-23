if Meteor.isClient
  Template.groupDocuments.onCreated ->
    @subscribe('groupDetail', @data.groupId)
    
  Template.groupDocuments.helpers
    group: ->
      Groups.findOne(@groupId)

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group?.viewableByUser(Meteor.user())
