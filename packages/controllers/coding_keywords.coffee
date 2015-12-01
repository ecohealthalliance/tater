if Meteor.isClient
  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @subHeaders = new Meteor.Collection(null)
    @keywords = new Meteor.Collection(null)
    @selectedHeader = new ReactiveVar('')
    @selectedSubHeader = new ReactiveVar('')
    @selectedKeyword = new ReactiveVar('')

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

  setKeywords = (selectedSubHeader) ->
    instance = Template.instance()
    instance.selectedSubHeader.set(selectedSubHeader)
    instance.keywords.remove({})
    keywords = CodingKeywords.find({'subHeaderId': selectedSubHeader._id, 'archived': {$ne: true}})
    _.each keywords.fetch(), (keyword) ->
      instance.keywords.insert keyword

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
        setKeywords(selectedSubHeader)

    'click .delete-keyword-button': (event) ->
      keywordId = event.target.parentElement.getAttribute("data-keyword-id")
      $('#keywordLabel').html(CodingKeywords.findOne(keywordId).label)
      $('#confirm-delete-keyword').attr("data-keyword-id", keywordId)

    'hidden.bs.modal #confirm-delete-keyword-modal': (event, instance) ->
      # since we are using a collection that exists only for this controller for keywords 
      # we need to rebind the keywords in order to get changes to show on the page after an update
      setKeywords(instance.selectedSubHeader.get())

    'click .code-level-3': (event, instance) ->
      instance.selectedKeyword.set($(event.currentTarget).text())
