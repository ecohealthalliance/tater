if Meteor.isClient
  SelectableCodes = new Meteor.Collection("SelectableCodes")

  Template.annotationsCodingKeywords.onCreated ->
    @searchText = new ReactiveVar('')
    @searching = new ReactiveVar(false)
    @filteredHeaders = new ReactiveVar()
    @filteredSubHeaders = new ReactiveVar()
    @filteredCodes = new ReactiveVar()
    @keywordQuery = @data.keywordQuery

  Template.annotationsCodingKeywords.onRendered ->
    instance = Template.instance()

    @autorun ->
      instance.subscribe(
        'codingKeywordsForDocuments',
        instance.keywordQuery.get(),
        { onStop: (err)-> if err then console.log(err) }
      )
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

  Template.annotationsCodingKeywords.helpers
    searching: () ->
      Template.instance().searching.get()

    filteredCodes: () ->
      Template.instance().filteredCodes.get()

    code: () ->
      Spacebars.SafeString("<span class='header'>#{@headerLabel()}</span> : <span class='sub-header'>#{@subHeaderLabel()}</span> : <span class='keyword'>#{@label}</span>")

    selectableHeaders: () ->
      if Template.instance().filteredHeaders.get()
        Template.instance().filteredHeaders.get()
      else
        Headers.find()

    selectableSubHeaders: (headerId) ->
      subHeaders = Template.instance().filteredSubHeaders.get()
      if Template.instance().filteredHeaders.get()
        _.filter subHeaders, (subHeader) =>
          subHeader?.headerId == headerId
      else
        SubHeaders.find(headerId: headerId)

    selectableKeywords: (subHeaderId) ->
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

    selectedHeader: (codeId) ->
      if Template.instance().data.selectedHeaders?.findOne(@_id)
        'selected'

    selectedSubHeader: ->
      if Template.instance().data.selectedSubHeaders?.findOne(@_id)
        'selected'

    selectedKeyword: (codeId) ->
      if Template.instance().data.selectedCodes?.findOne(@_id)
        'selected'

    selectedCodes: ->
      Template.instance().data.selectedCodes?.find().count()

  Template.annotationsCodingKeywords.events

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

    'click .clear-selected-codes': (e, instance) ->
      instance.data.selectedHeaders.remove({})
      instance.data.selectedSubHeaders.remove({})
      instance.data.selectedCodes.remove({})


if Meteor.isServer

  Meteor.publish 'codingKeywordsForDocuments', (keywordQuery) ->
    # We need to publish all the coding keywords so that the parent keywords can
    # be shown when only a child keyword is used in a selected document.
    # This presents a challenge because they cannot both use the same collection
    # so this subscription publishes results to a virtual collection
    # called SelectableCodes.
    user = Meteor.users.findOne({_id: @userId})
    if user
      annotations = Annotations.find(QueryHelpers.limitQueryToUserDocs(keywordQuery, user))
      codingKeywords = CodingKeywords.find({_id: {$in: _.uniq(_.pluck(annotations.fetch(), 'codeId'))}})
      subHeaders = SubHeaders.find({_id: {$in: _.uniq(_.pluck(codingKeywords.fetch(), 'subHeaderId'))}})
      headers = Headers.find({_id: {$in: _.uniq(_.pluck(subHeaders.fetch(), 'headerId'))}})
      [codingKeywords, subHeaders, headers]
    else
      @ready()
