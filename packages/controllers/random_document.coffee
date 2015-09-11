if Meteor.isClient
  Template.randomDocument.onCreated ->
    Meteor.call 'getRandomDocument', @data.groupId, (error, documentId) ->
      go 'documentDetail', {_id: documentId}, {generateCode: true}

if Meteor.isServer
  Meteor.methods
    getRandomDocument: (groupId) ->
      count = Documents.find({groupId: groupId}).count()
      random = Math.floor(Math.random() * count)
      documents = Documents.find({groupId: groupId}, {limit: -1, skip: random})
      documents.fetch()[0]._id
