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

    'createTestGroup': (attributes) ->
      group = new Group()
      group.set('name', 'test group')
      group.set('description', 'description')
      group.set('createdById', Meteor.users.findOne()._id)
      group.set('_id', "fakegroupid")
      group.save()

    'createProfile': (field, value, id) ->
      attributes = {}
      attributes[field] = value
      attributes['_id'] = id
      UserProfiles.insert attributes
