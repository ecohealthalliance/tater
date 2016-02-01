do ->

  'use strict'

  Meteor.methods

    resetFixture: ->
      Meteor.users.remove({})
      UserProfiles.remove({})
      Groups.remove({})
      Documents.remove({})
      Annotations.remove({})
      Headers.remove({})
      SubHeaders.remove({})
      CodingKeywords.remove({})
      Tenants.remove({})

    createTestUserFixture: (attributes) ->
      Meteor.users.remove({})
      account = Accounts.createUser
        email: attributes.email
        password: attributes.password
      userProfile = UserProfiles.findOne(userId: account)
      userProfile.update(
        fullName: attributes.fullName
      )
      Meteor.users.update(account, {
        $set: {admin: true, acceptedEULA: true}
      })

    setUserAccountPasswordFixture: (attributes) ->
      user = Meteor.users.findOne 'emails.address': attributes.email
      Accounts.setPassword user._id, attributes.password
      # Meteor.users.update { email: attributes.email }, $set: { password: attributes.password }

    createTestGroupFixture: (attributes) ->
      attributes ?= {}
      attributes.name ?= "Test Group"
      attributes.description ?= "Test Description"
      attributes.createdById ?= Meteor.users.findOne()._id
      attributes._id ?= "fakegroupid"
      Groups.remove(attributes._id)
      group = new Group()
      group.set(attributes)
      group.save()

    createProfileFixture: (field, value, id) ->
      userProfile = new UserProfile()
      attributes = {}
      attributes[field] = value
      attributes['_id'] = id
      userProfile.set(attributes)
      userProfile.save()

    createTestDocumentFixture: (attributes) ->
      document = new Document()
      attributes['body'] ?= 'Test Body'
      attributes['groupId'] ?= 'fakegroupid'
      attributes['accessCode'] ?= 'faketoken123'
      document.set(attributes)
      document.save()

    createTestAnnotationFixture: (attributes) ->
      annotation = new Annotation()
      attributes['documentId'] ?= 'fakedocumentid'
      attributes['userId'] ?= 'fakeuserid'
      attributes['startOffset'] ?= 0
      attributes['endOffset'] ?= 1
      annotation.set(attributes)
      annotation.save()

    createCodingKeywordFixture: (header, subHeader, keyword, color) ->
      headerDoc = Headers.findOne({label: header})
      headerId = if headerDoc then headerDoc._id else Headers.insert({label: header, color: 1})
      subHeaderDoc = SubHeaders.findOne({headerId: headerId, label: subHeader})
      subHeaderId = if subHeaderDoc then subHeaderDoc._id else SubHeaders.insert({headerId: headerId, label: subHeader})
      keywordId = CodingKeywords.insert(subHeaderId: subHeaderId, label: keyword)
