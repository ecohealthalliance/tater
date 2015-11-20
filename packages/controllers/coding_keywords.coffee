if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @subHeaders = new Meteor.Collection(null)
    @keywords = new Meteor.Collection(null)
    @selectedHeader = new ReactiveVar('')
    @selectedSubHeader = new ReactiveVar('')

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


  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeader = $(event.currentTarget).text()
      if selectedHeader != instance.selectedHeader.get()
        instance.selectedHeader.set(selectedHeader)
        instance.selectedSubHeader.set('')
        instance.subHeaders.remove({})
        instance.keywords.remove({})
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
        instance.keywords.remove({})
        keywords = CodingKeywords.find
          $and:
            [
              'subHeader': selectedSubHeader
              'keyword': $exists: true
            ]
        _.each keywords.fetch(), (keyword) ->
          instance.keywords.insert keyword

    'click .delete-keyword-button': (event) ->
      $('#confirm-delete-keyword').attr("data-keyword-id", event.target.parentElement.getAttribute("data-keyword-id"))

