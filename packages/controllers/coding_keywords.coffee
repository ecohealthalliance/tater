if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')

  Template.codingKeywords.helpers
    header: () ->
      headers = CodingKeywords.find
        $and:
          [
            'subHeader': $exists: false
            'keywords': $exists: false
          ]
      _.map headers.fetch(), (header, i) ->
        name: header.header
        index: i+1

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

  Template.codingKeywords.events
    'click .code-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-sub-headers').toggleClass('hidden')
    'click .code-sub-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-keywords').toggleClass('hidden').siblings('span').toggleClass('showing')

if Meteor.isServer
  Meteor.publish 'codingKeywords', () ->
    CodingKeywords.find()
