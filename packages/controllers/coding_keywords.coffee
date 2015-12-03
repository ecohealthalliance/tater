if Meteor.isClient

  Template.codingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @keywords = new Meteor.Collection(null)
    @subHeaders = new Meteor.Collection(null)
    @selectedCodes = new ReactiveDict()
    @addingCode = new ReactiveDict()
    @keywordToDelete = new ReactiveVar()
    @subHeaderToDelete = new ReactiveVar()
    @headerToDelete = new ReactiveVar()

  Template.codingKeywords.helpers
    headers: ->
      Headers.find()

    subHeaders: ->
      SubHeaders.find(headerId: Template.instance().selectedCodes.get('headerId'))

    keywords: ->
      Template.instance().keywords.find()

    selected: (level) ->
      if level == 'header'
        if @_id == Template.instance().selectedCodes.get('headerId')
          'selected'
      else
        if @_id == Template.instance().selectedCodes.get('subHeaderId')
          'selected'

    currentlySelectedHeader: ->
      Template.instance().selectedCodes.get('headerId')

    currentlySelectedSubHeader: ->
      Template.instance().selectedCodes.get('subHeaderId')

    currentlySelectedKeyword: ->
      Template.instance().selectedCodes.get('keywordId')

    addingCode: (level) ->
      Template.instance().addingCode.get(level)

    keywordToDelete: ->
      Template.instance().keywordToDelete.get()

    subHeaderToDelete: ->
      Template.instance().subHeaderToDelete.get()

    headerToDelete: ->
      Template.instance().headerToDelete.get()


  setKeywords = (selectedSubHeaderId) ->
    instance = Template.instance()
    instance.keywords.remove({})
    keywords = CodingKeywords.find({'subHeaderId': selectedSubHeaderId})
    _.each keywords.fetch(), (keyword) ->
      instance.keywords.insert keyword

  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeaderId = event.currentTarget.getAttribute('data-id')
      if selectedHeaderId != instance.selectedCodes.get('headerId')
        instance.selectedCodes.set('headerId', selectedHeaderId)
        instance.selectedCodes.set('subHeaderId', null)
        instance.selectedCodes.set('keywordId', null)
        instance.subHeaders.remove({})
        instance.keywords.remove({})
        instance.addingCode.set('keyword', false)
        instance.addingCode.set('subHeader', false)
        subHeaders = SubHeaders.find({headerId: selectedHeaderId})
        _.each subHeaders.fetch(), (subHeader) ->
          instance.subHeaders.insert subHeader

    'click .code-level-2': (event, instance) ->
      selectedSubHeaderId = event.currentTarget.getAttribute('data-id')

      if selectedSubHeaderId != instance.selectedCodes.get('subHeaderId')
        instance.selectedCodes.set('subHeaderId', selectedSubHeaderId)
        instance.selectedCodes.set('keywordId', '')
        instance.keywords.remove({})
        instance.addingCode.set('keyword', false)
        keywords = CodingKeywords.find({subHeaderId: selectedSubHeaderId})
        if keywords.count()
          _.each keywords.fetch(), (keyword) ->
            instance.keywords.insert keyword
        else
          instance.addingCode.set('keyword', true)

    'click .add-code': (event, instance) ->
      level = $(event.target).data('level')
      instance.addingCode.set(level, not instance.addingCode.get(level))

    'click .delete-subheader-button': (event, instance) ->
      subHeaderId = event.target.parentElement.getAttribute("data-subheader-id")
      instance.subHeaderToDelete.set(SubHeaders.findOne(subHeaderId))

    'click .delete-header-button': (event, instance) ->
      headerId = event.target.parentElement.getAttribute("data-header-id")
      instance.headerToDelete.set(Headers.findOne(headerId))

    'hidden.bs.modal .modal': (event, instance) ->
      # since we are using a collection that exists only for this controller for keywords
      # we need to rebind the keywords in order to get changes to show on the page after an update
      setKeywords(instance.selectedCodes.get('subHeaderId'))

    'click .adding-code .cancel': (event, instance) ->
      level = $(event.target).data('level')
      instance.addingCode.set(level, false)

    'keydown form input': (event, instance) ->
      if event.which == 27 # Esc
        formId = $(event.target).parent('form').attr('id')
        switch formId
          when "new-header-form" then instance.addingCode.set('header', false)
          when "new-subHeader-form" then instance.addingCode.set('subHeader', false)
          when "new-keyword-form" then instance.addingCode.set('keyword', false)

    'submit #new-header-form': (event, instance) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      headerProps =
        label: form.header.value
        color: form.color.value

      Meteor.call 'addHeader', headerProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Header added")
          form.reset()
        form.header.focus()

    'submit #new-subHeader-form': (event, instance) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      subHeaderProps =
        headerId: instance.selectedCodes.get('headerId')
        label: form.subHeader.value

      Meteor.call 'addSubHeader', subHeaderProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          instance.subHeaders.insert subHeaderProps
          toastr.success("Sub-Header added")
          form.subHeader.value = ''
        form.subHeader.focus()

    'submit #new-keyword-form': (event, instance) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      keywordProps =
        headerId: instance.selectedCodes.get('headerId')
        subHeaderId: instance.selectedCodes.get('subHeaderId')
        label: form.keyword.value

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          instance.keywords.insert keywordProps
          toastr.success("Keyword added")
          form.keyword.value = ''
        form.keyword.focus()

    'click .delete-keyword-button': (event, instance) ->
      keywordId = event.target.parentElement.getAttribute("data-keyword-id")
      instance.keywordToDelete.set(CodingKeywords.findOne(keywordId))

    'hidden.bs.modal #confirm-delete-keyword-modal': (event, instance) ->
      # since we are using a collection that exists only for this controller for keywords
      # we need to rebind the keywords in order to get changes to show on the page after an update
      setKeywords(instance.selectedCodes.get('subHeaderId'))

  Template.new_header_form.onRendered ->
    @$("input[name=header]").focus()
    @$('.color-picker').colorpicker()

  Template.new_subHeader_form.onRendered ->
    @$("input").focus()

  Template.new_keyword_form.onRendered ->
    @$("input").focus()



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

  _validateHeader(keywordProps.headerId)
  _validateSubheader(keywordProps.headerId, keywordProps.subHeaderId)

  if CodingKeywords.findOne(
    headerId: keywordProps.headerId
    subHeaderId: keywordProps.subHeaderId
    label: keywordProps.label
  ) then throw new Meteor.Error('Duplicate keyword')

  true

_validateSubHeaderProperties = (subHeaderProps) ->
  if not subHeaderProps.label
    throw new Meteor.Error('Sub-Header is empty')
  if not subHeaderProps.headerId
    throw new Meteor.Error('Header is required')

  _validateHeader(subHeaderProps.headerId)

  if SubHeaders.findOne(
    headerId: subHeaderProps.headerId
    label: subHeaderProps.label
  ) then throw new Meteor.Error('Duplicate sub-header')

  true

_validateHeaderProperties = (headerProps) ->
  if not headerProps.label
    throw new Meteor.Error('Header is empty')

  if Headers.findOne(
    label: headerProps.label
  ) then throw new Meteor.Error('Duplicate header')

  true

Meteor.methods
  addHeader: (headerProps) ->
    if Meteor.users.findOne(@userId)?.admin
      _headerProps =
        label: headerProps.label?.trim()
        color: headerProps.color

      if _validateHeaderProperties(_headerProps)
        Headers.insert _headerProps
    else
      throw new Meteor.Error('Unauthorized')

  addSubHeader: (subHeaderProps) ->
    if Meteor.users.findOne(@userId)?.admin
      _subHeaderProps =
        headerId: subHeaderProps.headerId
        label: subHeaderProps.label?.trim()

      if _validateSubHeaderProperties(_subHeaderProps)
        SubHeaders.insert _subHeaderProps
    else
      throw new Meteor.Error('Unauthorized')

  addKeyword: (keywordProps) ->
    if Meteor.users.findOne(@userId)?.admin
      _keywordProps =
        headerId: keywordProps.headerId
        subHeaderId: keywordProps.subHeaderId
        label: keywordProps.label?.trim()

      if _validateKeywordProperties(_keywordProps)
        CodingKeywords.insert _keywordProps
    else
      throw new Meteor.Error('Unauthorized')
