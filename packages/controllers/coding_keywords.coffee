if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')

  Template.codingKeywords.helpers
    headers: () ->
      CodingKeywords.find
        'subHeader': $exists: false
        'keywords': $exists: false

    subHeaders: (header) ->
      CodingKeywords.find
        'header': header
        'subHeader': $exists: true
        'keyword': $exists: false

    keywords: (subHeader) ->
      CodingKeywords.find
        'subHeader': subHeader
        'keyword': $exists: true

  Template.codingKeywords.events

    'click .code-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-sub-headers').toggleClass('hidden')

    'click .code-sub-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-keywords').toggleClass('hidden').siblings('span').toggleClass('showing')
