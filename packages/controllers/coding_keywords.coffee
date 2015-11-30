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
      Headers.find()

    subHeaders: ->
      Template.instance().subHeaders.find()

    keywords: ->
      Template.instance().keywords.find()

    selected: (level) ->
      if level == 'header'
        if @_id == Template.instance().selectedHeader.get()._id
          'selected'
      else
        if @_id == Template.instance().selectedSubHeader.get()._id
          'selected'

    currentlySelectedHeader: ->
      Template.instance().selectedHeader.get()?.label

    currentlySelectedSubHeader: ->
      Template.instance().selectedSubHeader.get()?.label

    currentlySelectedKeyword: ->
      Template.instance().selectedKeyword.get()?.label

    addingKeyword: ->
      Template.instance().addingKeyword.get()

  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeaderId = event.currentTarget.getAttribute('data-id')
      selectedHeader = Headers.findOne(selectedHeaderId)
      if selectedHeader != instance.selectedHeader.get()
        instance.selectedHeader.set(selectedHeader)
        instance.selectedSubHeader.set(null)
        instance.selectedKeyword.set(null)
        instance.subHeaders.remove({})
        instance.keywords.remove({})
        subHeaders = SubHeaders.find({headerId: selectedHeaderId})
        _.each subHeaders.fetch(), (subHeader) ->
          instance.subHeaders.insert subHeader

    'click .code-level-2': (event, instance) ->
      selectedSubHeaderId = event.currentTarget.getAttribute('data-id')
      selectedSubHeader = SubHeaders.findOne(selectedSubHeaderId)
      if selectedSubHeader != instance.selectedSubHeader.get()
        instance.selectedSubHeader.set(selectedSubHeader)
        instance.selectedKeyword.set(null)
        instance.keywords.remove({})
        keywords = CodingKeywords.find({subHeaderId: selectedSubHeaderId})
        _.each keywords.fetch(), (keyword) ->
          instance.keywords.insert keyword

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
