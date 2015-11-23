do ->

  'use strict'

  Meteor.methods

    'reset': ->
      Meteor.users.remove({})
      UserProfiles.remove({})
      Groups.remove({})
      Documents.remove({})
      Annotations.remove({})
      Headers.remove({})
      SubHeaders.remove({})
      CodingKeywords.remove({})

    'createTestUser': (attributes) ->
      Meteor.users.remove({})
      account = Accounts.createUser
        email: attributes.email
        password: attributes.password
      Meteor.users.update({_id: account}, {$set: {admin: true}})

    'createTestGroup': (codeAccessible) ->
      group = new Group()
      group.set
        name: "Test Group"
        description: "Test Description"
        createdById: Meteor.users.findOne()._id
        _id: "fakegroupid"
        codeAccessible: codeAccessible
      group.save()

    'createProfile': (field, value, id) ->
      userProfile = new UserProfile()
      attributes = {}
      attributes[field] = value
      attributes['_id'] = id
      userProfile.set(attributes)
      userProfile.save()

    'createTestDocument': (attributes) ->
      document = new Document()
      attributes['body'] ?= 'Test Body'
      attributes['groupId'] ?= 'fakegroupid'
      document.set(attributes)
      document.save()

    'createTestAnnotation': (attributes) ->
      annotation = new Annotation()
      attributes['documentId'] ?= 'fakedocumentid'
      attributes['userId'] ?= 'fakeuserid'
      attributes['startOffset'] ?= 0
      attributes['endOffset'] ?= 1
      annotation.set(attributes)
      annotation.save()

    'createCodingKeyword': (header, subHeader, keyword, color) ->
      headerId = Headers.insert(label: header, color: 1)
      subHeaderId = SubHeaders.insert(headerId: headerId, label: subHeader)
      CodingKeywords.insert(subHeaderId: subHeaderId, label: keyword)
