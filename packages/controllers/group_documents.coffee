if Meteor.isClient

  Template.groupDocuments.onCreated ->
    @subscribe 'groups', =>
      @subscribe 'documents', @data.groupId

  Template.groupDocuments.helpers
    group: ->
      Groups.findOne(@groupId)

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group?.viewableByUser(Meteor.user())
