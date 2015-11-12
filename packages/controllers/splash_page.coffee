if Meteor.isClient
  Template.splashPage.onCreated ->
    @subscribe('recentDocuments')

  Template.splashPage.helpers
    documentsExist: ->
      Documents.find().count()

    recentDocuments: ->
      Documents.find()

if Meteor.isServer
  Meteor.publish 'recentDocuments', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      Documents.find({}, {sort: {createdAt: -1}, limit: 12})
    else
      Documents.find({groupId: user.group}, {sort: {createdAt: -1}, limit: 12})
