do ->

  'use strict'

  Meteor.methods

    'reset': ->
      Meteor.users.remove({})
      UserProfiles.remove({})
      Groups.remove({})
      Documents.remove({})
      Annotations.remove({})
      CodingKeywords.remove({})

    'createTestUser': (attributes) ->
      Meteor.users.remove({})
      account = Accounts.createUser
        email: attributes.email
        password: attributes.password
      Meteor.users.update({_id: account}, {$set: {admin: true}})

    'createTestGroup': (codeAccessible) ->
      userId = Meteor.users.findOne()._id
      groupId = Groups.insert
        name: "Test Group"
        description: "Test Description"
        createdById: userId
        _id: "fakegroupid"
        codeAccessible: codeAccessible
      Meteor.users.update({_id: userId}, {$set: {group: groupId}})

    'createProfile': (field, value, id) ->
      attributes = {}
      attributes[field] = value
      attributes['_id'] = id
      UserProfiles.insert attributes

    'createTestDocument': (attributes) ->
      attributes['body'] ?= 'Test Body'
      attributes['groupId'] ?= 'fakegroupid'
      Documents.insert(attributes)

    'createTestAnnotation': (attributes) ->
      attributes['documentId'] ?= 'fakedocumentid'
      attributes['userId'] ?= 'fakeuserid'
      attributes['startOffset'] ?= 0
      attributes['endOffset'] ?= 1
      Annotations.insert(attributes)

    'createCodingKeyword': (attributes) ->
      CodingKeywords.insert(attributes)
