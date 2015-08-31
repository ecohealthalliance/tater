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
      account = Accounts.createUser
        email: attributes.email
        password: attributes.password
      Meteor.users.update({_id: account}, {$set: {admin: true}})

    'createTestGroup': (codeAccessible) ->
      Groups.insert
        name: "Test Group"
        description: "Test Description"
        createdById: Meteor.users.findOne()._id
        _id: "fakegroupid"
        codeAccessible: codeAccessible

    'createProfile': (field, value, id) ->
      attributes = {}
      attributes[field] = value
      attributes['_id'] = id
      UserProfiles.insert attributes

    'createTestDocument': (attributes) ->
      attributes['body'] = 'Test Body'
      Documents.insert(attributes)
