if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')

  Template.codingKeywords.helpers
    header: () ->
      CodingKeywords.find
        $and:
          [
            'subHeader': $exists: false
            'keywords': $exists: false
          ]
    subHeader: (header) ->
      CodingKeywords.find
        $and:
          [
            'header': header
            'subHeader': $exists: true
            'keyword': $exists: false
          ]
    keywords: (subHeader) ->
      CodingKeywords.find
        $and:
          [
            'subHeader': subHeader
            'keyword': $exists: true
          ]

if Meteor.isServer
  Meteor.publish 'codingKeywords', () ->
    CodingKeywords.find()
