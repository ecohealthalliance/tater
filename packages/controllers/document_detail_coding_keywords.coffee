if Meteor.isClient
  Template.documentDetailCodingKeywords.onCreated ->
    if @data.accessCode
      @subscribe('caseCountCodingKeywords')
    else
      @subscribe('codingKeywords')
      @subscribe('headers')
      @subscribe('subHeaders')
    @searchText = new ReactiveVar('')
    @searching = new ReactiveVar(false)
    @filteredHeaders = new ReactiveVar()
    @filteredSubHeaders = new ReactiveVar()
    @filteredCodes = new ReactiveVar()
    @selectableCodes = @data.selectableCodes

  Template.documentDetailCodingKeywords.onRendered ->
    instance = Template.instance()

    @autorun ->
      query = []
      searchText = instance.searchText.get()
      if searchText.length > 0
        _.each searchText.split(' '), (text) ->
          text = RegExp(text, 'i')
          query.push {'label': text}

        codingKeywordResults = CodingKeywords.find({$and: query})
        instance.filteredCodes.set codingKeywordResults
        subHeaderIds = _.uniq(_.pluck(codingKeywordResults.fetch(), 'subHeaderId'))

        subHeaderResults = SubHeaders.find({$or: [{$and: query}, {_id: {$in: subHeaderIds}}]})
        instance.filteredSubHeaders.set subHeaderResults
        headerIds = _.uniq(_.pluck(subHeaderResults.fetch(), 'headerId'))

        headerResults = Headers.find({$or: [{$and: query}, {_id: {$in: headerIds}}]})
        instance.filteredHeaders.set headerResults
      else
        instance.filteredHeaders.set null
        instance.filteredSubHeaders.set null
        instance.filteredCodes.set null

  Template.documentDetailCodingKeywords.helpers
    searching: () ->
      false
      # Template.instance().searching.get()

    filteredCodes: () ->
      Template.instance().filteredCodes.get()

    code: () ->
      if @header and @subHeader and @keyword
        Spacebars.SafeString("<span class='header'>#{@header}</span> : <span class='sub-header'>#{@subHeader}</span> : <span class='keyword'>#{@keyword}</span>")
      else if @subHeader and not @keyword
        Spacebars.SafeString("<span class='header'>#{@header}</span> : <span class='sub-header'>#{@subHeader}</span>")
      else
        Spacebars.SafeString("<span class='header'>"+@header+"</span>")

    headers: () ->
      if Template.instance().filteredHeaders.get()?.count()
        Template.instance().filteredHeaders.get()
      else
        Headers.find()

    subHeaders: (headerId) ->
      subHeaders = Template.instance().filteredSubHeaders.get()
      if subHeaders?.count()
        _.filter subHeaders.fetch(), (subHeader) =>
          subHeader?.headerId == headerId
      else
        SubHeaders.find(headerId: headerId)

    keywords: (subHeaderId) ->
      keywords = Template.instance().filteredCodes.get()
      if keywords?.count()
        _.filter keywords.fetch(), (keyword) =>
          keyword?.subHeaderId == subHeaderId
      else
        CodingKeywords.find(subHeaderId: subHeaderId)

    icon: ->
      if @header is 'Human Movement' then 'fa-bus'
      else if @header is 'Socioeconomics' then 'fa-money'
      else if @header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if @header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if @header is 'Human Animal Contact' then 'fa-paw'
      else 'fa-ellipsis-h'

  Template.documentDetailCodingKeywords.events

    'keyup .code-search': _.debounce ((e, instance) ->
      e.preventDefault()
      searchText = e.target.value
      if searchText.length > 1 then instance.searching.set true
      else instance.searching.set false
      instance.searchText.set e.target.value
      ), 100

    'click .clear-search': (e, instance) ->
      instance.searching.set false
      instance.searchText.set ''
      $('.code-search').val('')

    'click .code-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-sub-headers').toggleClass('hidden')

    'click .code-sub-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-keywords').toggleClass('hidden').siblings('span').toggleClass('showing')

if Meteor.isServer
  Meteor.publish 'headers', () ->
    Headers.find()
  Meteor.publish 'subHeaders', () ->
    SubHeaders.find()
  Meteor.publish 'codingKeywords', () ->
    CodingKeywords.find(caseCount: {$ne: true})
  Meteor.publish 'caseCountCodingKeywords', () ->
    CodingKeywords.find(caseCount: true)
