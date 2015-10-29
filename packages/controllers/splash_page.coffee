if Meteor.isClient
  Template.splashPage.onCreated ->
    @subscribe('recentDocuments')
    # @subscribe('userDocuments')

  Template.splashPage.helpers
    documentsExist: ->
      Documents.find().count()

    recentDocuments: ->
      console.log Documents.find().fetch()
      Documents.find()

if Meteor.isServer
  Meteor.publish 'recentDocuments', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      Documents.find({}, {sort: {createdAt: -1}, limit: 12})
    else
      Documents.find({groupId: user.group}, {sort: {createdAt: -1}, limit: 12})
