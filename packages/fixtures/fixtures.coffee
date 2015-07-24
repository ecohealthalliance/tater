do ->

  'use strict'

  Meteor.methods

    'reset': ->
      Meteor.users.remove({})
      UserProfiles.remove({})
      Groups.remove({})
      Documents.remove({})

    'createTestUser': (attributes) ->
      Meteor.users.remove({})
      Accounts.createUser
        email: attributes.email
        password: attributes.password

    'createTestGroup': ->
      Groups.insert
        name: "Test Group"
        description: "Test Description"
        createdById: Meteor.users.findOne()._id
        _id: "fakegroupid"

    'createProfile': (field, value, id) ->
      attributes = {}
      attributes[field] = value
      attributes['_id'] = id
      UserProfiles.insert attributes

    'createTestDocument': (attributes) ->
      Documents.insert
        title: attributes.title
        body: "Test Body"
        groupId: attributes.groupId
