if Meteor.isClient
  Template.codingKeywords.onCreated ->
    if @data.accessCode
      @subscribe('caseCountCodingKeywords')
    else
      @subscribe('codingKeywords')
    @searchText = new ReactiveVar('')
    @filtering = new ReactiveVar(false)
    @filteredCodes = new ReactiveVar()
    @selectableCodeIds = @data.selectableCodeIds

  Template.codingKeywords.onRendered ->
    instance = Template.instance()

    @autorun ->
      query = []
      searchText = instance.searchText.get().split(' ')
      _.each searchText, (text) ->
        text = RegExp(text, 'i')
        query.push $or: [{'header': text}, {'subHeader': text}, {'keyword': text}]
      results = CodingKeywords.find({$and: query}, {sort: {header: 1, subHeader: 1, keyword: 1}})

      instance.filteredCodes.set results

  Template.codingKeywords.helpers
    filtering: () ->
      Template.instance().filtering.get()

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
        $and:
          [
            'subHeader': $exists: false
            'keywords': $exists: false
          ]

    subHeaders: (header) ->
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

    icon: ->
      if @header is 'Human Movement' then 'fa-bus'
      else if @header is 'Socioeconomics' then 'fa-money'
      else if @header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if @header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if @header is 'Human Animal Contact' then 'fa-paw'

    coding: ->
      Template.instance().data.action is 'coding'

    selectable: (element, level, id) ->
      if level is 'filtered'
        'selectable-code'
      else if element is 'code'
        selectable(level, 'selectable-code', @header, @subHeader, @keyword, @_id)
      else
        selectable(level, 'selectable', @header, @subHeader, @keyword, @_id)

    selected: (codeId) ->
      if Template.instance().data.selectedCodes.findOne(@_id)
        'selected'

    selectedCodes: ->
      Template.instance().data.selectedCodes?.find().count()

    showList: (level, showClass) ->
      if hasAnnotations(level, @header, @subHeader)
        if showClass
          'showing'
      else
        'hidden'

    toggleDirection: (level) ->
      if hasAnnotations(level, @header, @subHeader)
        'up'
      else
        'down'

    position: () ->
      if @location is 'right' then 'r' else 'l'

  hasAnnotations = (level, header, subHeader) ->
    if level is 'header'
      checkCode({header:header}).length
    else if level is 'subHeader'
      checkCode({subHeader:subHeader}).length

  selectable = (level, className, header, subHeader, keyword, id) ->
    if level is 'header'
      if checkCode({header:header}).length
        className
    else if level is 'subHeader'
      if checkCode({subHeader:subHeader}).length
        className
    else if level is 'keyword'
      if Annotations.findOne({codeId:CodingKeywords.findOne({keyword:keyword})._id})
        className
    else
      if checkCode({_id: id}).length
        className

  checkCode = (query) ->
    query._id = {$in: Template.instance().selectableCodeIds.get()}
    CodingKeywords.find(query).fetch()

  Template.codingKeywords.events

    'keyup .code-search': _.debounce ((e, instance) ->
      e.preventDefault()
      searchText = e.target.value
      if searchText.length > 1 then instance.filtering.set true
      else instance.filtering.set false
      instance.searchText.set e.target.value
      ), 100

    'click .clear-search': (e, instance) ->
      instance.filtering.set false
      instance.searchText.set ''
      $('.code-search').val('')

    'click .code-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-sub-headers').toggleClass('hidden')

    'click .code-sub-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-keywords').toggleClass('hidden').siblings('span').toggleClass('showing')

    'click .clear-selected-codes': (e, instance) ->
      instance.data.selectedCodes.remove({})


if Meteor.isServer
  Meteor.publish 'codingKeywords', () ->
    CodingKeywords.find(caseCount: {$ne: true})
  Meteor.publish 'caseCountCodingKeywords', () ->
    CodingKeywords.find(caseCount: true)
