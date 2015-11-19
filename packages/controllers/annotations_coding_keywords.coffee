if Meteor.isClient
  SelectableCodes = new Meteor.Collection("SelectableCodes")

  Template.annotationsCodingKeywords.onCreated ->
    @subscribe('codingKeywords')
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

      results = CodingKeywords.find({$and: query}, {sort: {header: 1, subHeader: 1, keyword: 1}})
      instance.filteredCodes.set results

  Template.annotationsCodingKeywords.helpers
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

    selectableHeaders: () ->
      headerNames = _.uniq _.pluck SelectableCodes.find().fetch(), 'header'
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
      subHeaderNames = _.uniq _.pluck _.filter(SelectableCodes.find().fetch(), (code) -> code.header == header and code.subHeader), 'subHeader'
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
      keywordIds = _.pluck _.filter(SelectableCodes.find().fetch(), (code) -> code.subHeader == subHeader and code.keyword), '_id'
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

    selected: (codeId) ->
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
  limitQueryToUserDocs = (query, user)->
    if user?.admin
      codeInaccessibleGroups = Groups.find({codeAccessible: {$ne: true}})
      codeInaccessibleGroupIds = _.pluck(codeInaccessibleGroups.fetch(), '_id')
      documents = Documents.find({groupId: {$in: codeInaccessibleGroupIds}})
    else
      documents = Documents.find({ groupId: user.group })
    docIds = documents.map((d)-> d._id)
    if query.documentId
      if _.isString query.documentId
        userDocIds = [query.documentId]
      else if query.documentId.$in
        userDocIds = query.documentId.$in
      else
        throw Meteor.Error("Query is not supported")
      if _.difference(userDocIds, docIds).length > 0
        throw Meteor.Error("Invalid docIds")
    else
      query.documentId = {$in: docIds}
    return query

  Meteor.publish 'codingKeywordsForDocuments', (keywordQuery) ->
    # We need to publish all the coding keywords so that the parent keywords can
    # be shown when only a child keyword is used in a selected document.
    # This presents a challenge because they cannot both use the same collection
    # so this subscription publishes results to a virtual collection
    # called SelectableCodes.
    user = Meteor.users.findOne({_id: @userId})
    if user
      annotations = Annotations.find(limitQueryToUserDocs(keywordQuery, user))
      CodingKeywords.find(
        _id:
          $in: _.uniq(_.pluck(annotations.fetch(), 'codeId'))
      ).forEach (codingKw)=>
        @added( "SelectableCodes", codingKw._id, codingKw )
      @ready()
    else
      @ready()
