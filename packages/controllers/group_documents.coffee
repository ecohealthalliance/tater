if Meteor.isClient
  Template.groupDocuments.onCreated ->
    @subscribe('groupDocuments', @data.groupId)

  Template.groupDocuments.helpers
    group: ->
      Groups.findOne(@groupId)

    documents: ->
      Documents.find({}, {groupId: @groupId})

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group.viewableByUserWithGroup(Meteor.user()?.group)


if Meteor.isServer
  Meteor.publish 'groupDocuments', (id) ->
    user = Meteor.users.findOne(@userId)
    group = Groups.findOne(id)

    if user and group.viewableByUserWithGroup(user.group)
      [
        Groups.find(id)
        Groups.findOne(id).documents()
      ]