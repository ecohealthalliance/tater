if Meteor.isClient
  SelectableCodes = new Meteor.Collection("SelectableCodes")

  Template.annotationsCodingKeywords.onCreated ->
    @searchText = new ReactiveVar('')
    @searching = new ReactiveVar(false)
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
      searchText = instance.searchText.get().split(' ')
      _.each searchText, (text) ->
        text = RegExp(text, 'i')
        query.push $or: [{'header': text}, {'subHeader': text}, {'keyword': text}]

      query.push {_id: {$in: SelectableCodes.find().map((c)->c._id)}}

      results = CodingKeywords.find({$and: query}, {sort: {headerId: 1, subHeaderId: 1, label: 1}})
      instance.filteredCodes.set results

  Template.annotationsCodingKeywords.helpers
    searching: () ->
      Template.instance().searching.get()

    filteredCodes: () ->
      Template.instance().filteredCodes.get()

    code: () ->
      Spacebars.SafeString("<span class='header'>#{@headerLabel()}</span> : <span class='sub-header'>#{@subHeaderLabel()}</span> : <span class='keyword'>#{@label}</span>")

    selectableHeaders: () ->
      Headers.find()

    selectableSubHeaders: (headerId) ->
      SubHeaders.find(headerId: headerId)

    selectableKeywords: (subHeaderId) ->
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
