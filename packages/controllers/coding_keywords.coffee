if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @subHeaders = new Meteor.Collection(null)
    @keywords = new Meteor.Collection(null)
    @selectedCodes = new ReactiveDict()
    @addingCode = new ReactiveDict()

  Template.codingKeywords.helpers
    headers: () ->
      CodingKeywords.find
        'subHeader': $exists: false
        'keywords': $exists: false

    subHeaders: ->
      Template.instance().subHeaders.find()

    keywords: ->
      Template.instance().keywords.find()

    selected: (level) ->
      if level == 'header'
        if @header == Template.instance().selectedCodes.get('header')
          'selected'
      else
        if @subHeader == Template.instance().selectedCodes.get('subHeader')
          'selected'

    currentlySelectedHeader: ->
      Template.instance().selectedCodes.get('header')

    currentlySelectedSubHeader: ->
      Template.instance().selectedCodes.get('subHeader')

    currentlySelectedKeyword: ->
      Template.instance().selectedCodes.get('keyword')

    addingCode: (level) ->
      console.log Template.instance().addingCode.get(level)
      Template.instance().addingCode.get(level)

  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeader = $(event.currentTarget).text()
      if selectedHeader != instance.selectedCodes.get('header')
        instance.selectedCodes.set('header', selectedHeader)
        instance.selectedCodes.set('subHeader', '')
        instance.selectedCodes.set('keywords', '')
        instance.subHeaders.remove({})
        instance.keywords.remove({})
        instance.addingCode.set('keyword', false)
        instance.addingCode.set('subHeader', false)
        subHeaders = CodingKeywords.find
          $and:
            [
              'header': selectedHeader
              'subHeader': $exists: true
              'keyword': $exists: false
            ]
        _.each subHeaders.fetch(), (subHeader) ->
          instance.subHeaders.insert subHeader

    'click .code-level-2': (event, instance) ->
      selectedSubHeader = $(event.currentTarget).text()
      if selectedSubHeader != instance.selectedCodes.get('subHeader')
        instance.selectedCodes.set('subHeader', selectedSubHeader)
        instance.selectedCodes.set('keywords', '')
        instance.keywords.remove({})
        instance.addingCode.set('keyword', false)
        keywords = CodingKeywords.find
          $and:
            [
              'subHeader': selectedSubHeader
              'keyword': $exists: true
            ]
        if keywords.count()
          _.each keywords.fetch(), (keyword) ->
            instance.keywords.insert keyword
        else
          instance.addingCode.set('keyword', true)

    'click .code-level-3': (event, instance) ->
      instance.selectedCodes.set('keyword', $(event.currentTarget).text())

    'click .add-code': (event, instance) ->
      instance.addingCode.set($(event.target).data('level'), true)

    'click .adding-code .cancel': (event, instance) ->
      instance.addingCode.set($(event.target).data('level'), false)

    'submit #new-subHeader-form': (event, instance) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      keywordProps =
        header: instance.selectedCodes.get('header')
        subHeader: form.subHeader.value

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          instance.subHeaders.insert keywordProps
          toastr.success("Sub-Header added")
          form.keyword.value = ''


    'submit #new-keyword-form': (event, instance) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      keywordProps =
        header: instance.selectedCodes.get('header')
        subHeader: instance.selectedCodes.get('subHeader')
        keyword: form.keyword.value

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          instance.keywords.insert keywordProps
          toastr.success("Keyword added")
          form.keyword.value = ''
