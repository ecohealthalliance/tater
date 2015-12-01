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
        if @_id == Template.instance().selectedHeader.get()?._id
          'selected'
      else
        if @_id == Template.instance().selectedSubHeader.get()?._id
          'selected'

    currentlySelectedHeader: ->
      Template.instance().selectedHeader.get()

    currentlySelectedSubHeader: ->
      Template.instance().selectedSubHeader.get()

    currentlySelectedKeyword: ->
      Template.instance().selectedKeyword.get()

    addingKeyword: ->
      Template.instance().addingKeyword.get()

  setKeywords = (selectedSubHeader) ->
    instance = Template.instance()
    instance.selectedSubHeader.set(selectedSubHeader)
    instance.keywords.remove({})
    keywords = CodingKeywords.find({'subHeaderId': selectedSubHeader._id})
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
      $('#confirm-delete-keyword').attr("data-keyword-id", event.target.parentElement.getAttribute("data-keyword-id"))

    'hidden.bs.modal #confirm-delete-keyword-modal': (event, instance) ->
      # since we are using a collection that exists only for this controller for keywords 
      # we need to rebind the keywords in order to get changes to show on the page after an update
      setKeywords(instance.selectedSubHeader.get())

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
        headerId: instance.selectedHeader.get()?._id
        subHeaderId: instance.selectedSubHeader.get()?._id
        label: form.keyword.value

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          instance.keywords.insert keywordProps
          toastr.success("Keyword added")
          form.keyword.value = ''


if Meteor.isServer

  _validateHeader = (headerId) ->
    if not Headers.findOne(headerId)
      throw new Meteor.Error("""The header does not exist.
    Omit the keyword and sub-header fields to create it before adding the keyword.""")

  _validateSubheader = (headerId, subHeaderId) ->
    if not SubHeaders.findOne(
      _id: subHeaderId
      headerId: headerId
    ) then throw new Meteor.Error("""The sub-header does not belong to the
    given header or does not exist.""")

  _validateKeywordProperties = (keywordProps) ->
    if not keywordProps.label
      throw new Meteor.Error('Keyword is empty')
    if not keywordProps.headerId
      throw new Meteor.Error('Header is required')
    if not keywordProps.subHeaderId
      throw new Meteor.Error('Sub-header is required')

    if CodingKeywords.findOne(
      headerId: keywordProps.headerId
      subHeaderId: keywordProps.subHeaderId
      label: keywordProps.label
    ) then throw new Meteor.Error('Duplicate keyword')

    _validateHeader(keywordProps.headerId)
    _validateSubheader(keywordProps.headerId, keywordProps.subHeaderId)

    true

  Meteor.methods
    addKeyword: (keywordProps) ->
      if Meteor.users.findOne(@userId)?.admin
        _keywordProps =
          headerId: keywordProps.headerId
          subHeaderId: keywordProps.subHeaderId
          label: keywordProps.label?.trim()

        if _validateKeywordProperties(_keywordProps)
          color = Headers.findOne({headerId: _keywordProps.headerId})?.color
          keywordProps.color = color or 1
          CodingKeywords.insert _keywordProps
      else
        throw new Meteor.Error('Unauthorized')
