if Meteor.isClient
  Template.documentDetailCodingKeywords.onCreated ->
    if @data.accessCode
      @subscribe('caseCountCodingKeywords')
    else
      @subscribe('codingKeywords')
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
        escapedSearchText = StringHelpers.escapeRegex(searchText)
        _.each escapedSearchText.split(' '), (text) ->
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
        childKeywords = CodingKeywords.find({subHeaderId: {$in: _.pluck(childOrResultSubHeaders, '_id')}}).fetch()

        filteredCodes = codingKeywordResults.concat(childKeywords)
        filteredSubHeaders = subHeaderResults.concat(parentSubHeaders).concat(childSubHeaders)
        filteredHeaders = headerResults.concat(parentHeaders)

        instance.filteredCodes.set(_.uniq filteredCodes, (code) -> code._id)
        instance.filteredSubHeaders.set(_.uniq filteredSubHeaders, (subHeader) -> subHeader._id)
        instance.filteredHeaders.set(_.uniq filteredHeaders, (header) -> header._id)
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
        CodingKeywords.find({subHeaderId: subHeaderId})

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
  Meteor.publish 'codingKeywords', () ->
    [
      Headers.find()
      SubHeaders.find({archived: {$ne: true}})
      CodingKeywords.find({caseCount: {$ne: true}, archived: {$ne: true}})
    ]

  # Published name is somewhat misleading - this includes both archived and 
  # unarchived keywords.  Named it this way so people will think twice before using.
  Meteor.publish 'archivedCodingKeywords', () ->
    [
      Headers.find()
      SubHeaders.find()
      CodingKeywords.find(caseCount: {$ne: true})
    ]
  Meteor.publish 'caseCountCodingKeywords', () ->
    CodingKeywords.find({caseCount: true, archived: {$ne: true}})
