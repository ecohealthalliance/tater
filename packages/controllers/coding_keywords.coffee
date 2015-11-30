if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @subHeaders = new Meteor.Collection(null)
    @keywords = new Meteor.Collection(null)
    @selectedHeader = new ReactiveVar('')
    @selectedSubHeader = new ReactiveVar('')
    @selectedKeyword = new ReactiveVar('')
    @addingKeyword = new ReactiveVar(false)

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
        if @header == Template.instance().selectedHeader.get()
          'selected'
      else
        if @subHeader == Template.instance().selectedSubHeader.get()
          'selected'

    currentlySelectedHeader: ->
      Template.instance().selectedHeader.get()

    currentlySelectedSubHeader: ->
      Template.instance().selectedSubHeader.get()

    currentlySelectedKeyword: ->
      Template.instance().selectedKeyword.get()

    addingKeyword: ->
      Template.instance().addingKeyword.get()

  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeader = $(event.currentTarget).text()
      if selectedHeader != instance.selectedHeader.get()
        instance.selectedHeader.set(selectedHeader)
        instance.selectedSubHeader.set('')
        instance.selectedKeyword.set('')
        instance.subHeaders.remove({})
        instance.keywords.remove({})
        instance.addingKeyword.set(false)
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
      if selectedSubHeader != instance.selectedSubHeader.get()
        instance.selectedSubHeader.set(selectedSubHeader)
        instance.selectedKeyword.set('')
        instance.keywords.remove({})
        instance.addingKeyword.set(false)
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
          instance.addingKeyword.set(true)

    'click .code-level-3': (event, instance) ->
      instance.selectedKeyword.set($(event.currentTarget).text())

    'click .add-keyword': (event, instance) ->
      instance.addingKeyword.set(true)

    'click .cancel-keyword': (event, instance) ->
      instance.addingKeyword.set(false)

    'submit #new-keyword-form': (event, instance) ->
          event.preventDefault()
          event.stopImmediatePropagation()
          form = event.target
          keywordProps =
            header: instance.selectedHeader.get()
            subHeader: instance.selectedSubHeader.get()
            keyword: form.keyword.value

          Meteor.call 'addKeyword', keywordProps, (error, response) ->
            if error
              toastr.error("Error: #{error.message}")
            else
              instance.keywords.insert keywordProps
              toastr.success("Keyword added")
              form.keyword.value = ''

    'submit #new-subheader-form': (event, instance) ->
          event.preventDefault()
          event.stopImmediatePropagation()
          form = event.target
          keywordProps =
            header: instance.selectedHeader.get()
            subHeader: form.subHeader.value

          Meteor.call 'addKeyword', keywordProps, (error, response) ->
            if error
              toastr.error("Error: #{error.message}")
            else
              instance.subHeaders.insert keywordProps
              toastr.success("Sub-Header added")
              $('#add-subheader-modal').modal('hide')
