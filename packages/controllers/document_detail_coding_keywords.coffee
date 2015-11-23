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

        # Find Coding Keywords, SubHeaders, and Headers that match the query
        codingKeywordResults = CodingKeywords.find({$and: query}).fetch()
        subHeaderResults = SubHeaders.find({$and: query}).fetch()
        headerResults = Headers.find({$and: query}).fetch()

        # For each keyword or subheader result, get its parents
        parentSubHeaderIds = _.pluck(codingKeywordResults, 'subHeaderId')
        parentSubHeaders = SubHeaders.find(_id: {$in: parentSubHeaderIds}).fetch()
        parentOrResultSubHeaders = _.union(parentSubHeaders, subHeaderResults)
        headerIds = _.uniq(_.pluck(parentOrResultSubHeaders, 'headerId'))
        parentHeaders = Headers.find(_id: {$in: headerIds}).fetch()

        # For each header or subheader result, get its children
        headerIds = _.pluck(headerResults, '_id')
        childSubHeaders = SubHeaders.find({headerId: {$in: headerIds}}).fetch()
        childOrResultSubHeaders = _.union(childSubHeaders, subHeaderResults)
        childKeywords = CodingKeywords.find(subHeaderId: {$in: _.pluck(childOrResultSubHeaders, '_id')}).fetch()

        instance.filteredCodes.set _.union(codingKeywordResults, childKeywords)
        instance.filteredSubHeaders.set _.union(subHeaderResults, parentSubHeaders, childSubHeaders)
        instance.filteredHeaders.set _.union(headerResults, parentHeaders)

      else
        instance.filteredHeaders.set null
        instance.filteredSubHeaders.set null
        instance.filteredCodes.set null

  Template.documentDetailCodingKeywords.helpers
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
      if Template.instance().filteredHeaders.get()
        Template.instance().filteredHeaders.get()
      else
        Headers.find()

    subHeaders: (headerId) ->
      subHeaders = Template.instance().filteredSubHeaders.get()
      if Template.instance().filteredHeaders.get()
        _.filter subHeaders, (subHeader) =>
          subHeader?.headerId == headerId
      else
        SubHeaders.find(headerId: headerId)

    keywords: (subHeaderId) ->
      keywords = Template.instance().filteredCodes.get()
      if Template.instance().filteredHeaders.get()
        _.filter keywords, (keyword) =>
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
