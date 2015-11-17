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

    icon: ->
      if @header is 'Human Movement' then 'fa-bus'
      else if @header is 'Socioeconomics' then 'fa-money'
      else if @header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if @header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if @header is 'Human Animal Contact' then 'fa-paw'
      else 'fa-ellipsis-h'

  Template.codingKeywords.events

    'click .code-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-sub-headers').toggleClass('hidden')

    'click .code-sub-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-keywords').toggleClass('hidden').siblings('span').toggleClass('showing')
