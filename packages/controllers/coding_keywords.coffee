if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @searchText = new ReactiveVar('')
    @filtering = new ReactiveVar(false)
    @filteredCodes = new ReactiveVar()

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

    selectable: (selectedId, element, filtered) ->
      if Annotations.findOne({codeId: selectedId}) and element is 'code'
        'selectable-code'
      else if Annotations.findOne({codeId: selectedId})
        'selectable'

    selected: (codeId) ->
      if Template.instance().data.selectedCodes.findOne({ "codeKeyword._id": @_id })
        'selected'

    selectedCodes: ->
      Template.instance().data.selectedCodes.find().count()

  Template.codingKeywords.events

    'keyup .code-search': _.debounce ((e, instance) ->
      e.preventDefault()
      searchText = e.target.value
      if searchText.length > 1 then instance.filtering.set true
      else instance.filtering.set false
      instance.searchText.set e.target.value
      ), 200

    'click .code-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-sub-headers').toggleClass('hidden')

    'click .code-sub-header > i': (e) ->
      $(e.target).toggleClass('down up').siblings('.code-keywords').toggleClass('hidden').siblings('span').toggleClass('showing')

    'click .clear-selected-codes': (e, instance) ->
      instance.data.selectedCodes.remove({})

if Meteor.isServer
  Meteor.publish 'codingKeywords', () ->
    CodingKeywords.find()
