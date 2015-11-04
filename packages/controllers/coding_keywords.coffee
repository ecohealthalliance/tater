if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @searchText = new ReactiveVar('')
    @searching = new ReactiveVar(false)
    @filteredCodes = new ReactiveVar()
    @selectableCodes = @data.selectableCodes

  Template.codingKeywords.onRendered ->
    instance = Template.instance()

    @autorun ->
      groupIds = _.chain(instance.data?.selectedGroups?.find()?.fetch() or [])
        .pluck("id")
        .uniq()
        .value()
      if instance.data.accessCode
        instance.subscribe('caseCountCodingKeywords')
      else
        instance.subscribe('codingKeywords', instance.data?.groupId or groupIds, true)
      query = []
      searchText = instance.searchText.get().split(' ')
      _.each searchText, (text) ->
        text = RegExp(text, 'i')
        query.push $or: [{'header': text}, {'subHeader': text}, {'keyword': text}]

      if instance.selectableCodes?.get()
        codeIds = _.pluck instance.selectableCodes.get(), '_id'
        query.push {_id: {$in: codeIds}}

      results = CodingKeywords.find({$and: query}, {sort: {header: 1, subHeader: 1, keyword: 1}})
      instance.filteredCodes.set results

  Template.codingKeywords.helpers
    searching: () ->
      Template.instance().searching.get()

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

    selectableHeaders: () ->
      headerNames = _.uniq _.pluck Template.instance().selectableCodes.get(), 'header'
      headers = CodingKeywords.find
        $and:
          [
            'subHeader': $exists: false
            'keyword': $exists: false
            'header': $in: headerNames
          ]
      if headers.count()
        headers

    selectableSubHeaders: (header) ->
      subHeaderNames = _.uniq _.pluck _.filter(Template.instance().selectableCodes.get(), (code) -> code.header == header and code.subHeader), 'subHeader'
      subHeaders = CodingKeywords.find
        $and:
          [
            'header': header
            'subHeader': $exists: true
            'keyword': $exists: false
            'subHeader': $in: subHeaderNames
          ]
      if subHeaders.count()
        subHeaders

    selectableKeywords: (subHeader) ->
      keywordIds = _.pluck _.filter(Template.instance().selectableCodes.get(), (code) -> code.subHeader == subHeader and code.keyword), '_id'
      keywords = CodingKeywords.find
        $and:
          [
            '_id': $in: keywordIds
          ]
      if keywords.count()
        keywords

    icon: ->
      if @header is 'Human Movement' then 'fa-bus'
      else if @header is 'Socioeconomics' then 'fa-money'
      else if @header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if @header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if @header is 'Human Animal Contact' then 'fa-paw'
      else 'fa-ellipsis-h'

    coding: ->
      Template.instance().data.action is 'coding'

    selected: (codeId) ->
      if Template.instance().data.selectedCodes.findOne(@_id)
        'selected'

    selectedCodes: ->
      Template.instance().data.selectedCodes?.find().count()

    position: () ->
      if @location is 'right' then 'r' else 'l'

  Template.codingKeywords.events

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
  Meteor.publish 'codingKeywords', (groupIdOrIds, returnDefaults) ->
    if _.isString(groupIdOrIds)
      groupIds = [groupIdOrIds]
    else if _.isArray(groupIdOrIds)
      groupIds = groupIdOrIds
    else
      groupIds = [null]
    results = CodingKeywords.find
      groupId: {$in: groupIds}
      caseCount: {$ne: true}
    if returnDefaults
      if _.every(groupIds, (id)-> CodingKeywords.findOne({groupId: id}))
        results
      else
        # If a group has no keywords include the initial default keywords.
        CodingKeywords.find
          groupId: {$in: groupIds.concat(null)}
          caseCount: {$ne: true}
    else
      results
  Meteor.publish 'caseCountCodingKeywords', () ->
    CodingKeywords.find(caseCount: true)
