if Meteor.isClient
  Template.randomDocument.onCreated ->
    subscription = @subscribe('randomDocument', @data.groupId)
    Meteor.autorun ->
      if subscription.ready()
        document = Documents.findOne()
        go 'documentDetail', {_id: document._id}, {generateCode: true}

if Meteor.isServer
  Meteor.publish 'randomDocument', (groupId) ->
    count = Documents.find({groupId: groupId}).count()
    random = Math.floor(Math.random() * count)
    Documents.find({groupId: groupId}, {limit: -1, skip: random})
