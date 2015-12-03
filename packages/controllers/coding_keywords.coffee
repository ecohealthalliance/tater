if Meteor.isClient

  Template.codingKeywords.onCreated ->
    @subscribe('Headers')
    @selectedCodes = new ReactiveDict()
    @addingCode = new ReactiveDict()
    @keywordToDelete = new ReactiveVar()
    @subHeaderToDelete = new ReactiveVar()
    @headerToDelete = new ReactiveVar()

  Template.codingKeywords.helpers
    headers: ->
      Headers.find()

    subHeaders: ->
      selectedHeaderId = Template.instance().selectedCodes.get('headerId')
      Meteor.subscribe 'subHeaders', selectedHeaderId
      SubHeaders.find headerId: selectedHeaderId

    keywords: ->
      instance = Template.instance()
      selectedSubHeaderId = instance.selectedCodes.get('subHeaderId')
      Meteor.subscribe 'Keywords', selectedSubHeaderId
      CodingKeywords.find subHeaderId: selectedSubHeaderId

    selected: (level) ->
      if level == 'header'
        if @_id == Template.instance().selectedCodes.get('headerId')
          'selected'
      else
        if @_id == Template.instance().selectedCodes.get('subHeaderId')
          'selected'

    archived: () ->
      if @archived
        'disabled'

    currentlySelectedHeader: ->
      Template.instance().selectedCodes.get('headerId')

    currentlySelectedSubHeader: ->
      Template.instance().selectedCodes.get('subHeaderId')

    addingCode: (level) ->
      Template.instance().addingCode.get(level)

    keywordToDelete: ->
      Template.instance().keywordToDelete.get()

    subHeaderToDelete: ->
      Template.instance().subHeaderToDelete.get()

    headerToDelete: ->
      Template.instance().headerToDelete.get()

  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeaderId = event.currentTarget.getAttribute('data-id')
      if selectedHeaderId != instance.selectedCodes.get('headerId')
        instance.selectedCodes.set('headerId', selectedHeaderId)
        instance.selectedCodes.set('subHeaderId', null)
        instance.selectedCodes.set('keywordId', null)
        instance.addingCode.set('keyword', false)
        instance.addingCode.set('subHeader', false)

    'click .code-level-2': (event, instance) ->
      selectedSubHeaderId = event.currentTarget.getAttribute('data-id')
      if selectedSubHeaderId != instance.selectedCodes.get('subHeaderId')
        instance.selectedCodes.set('subHeaderId', selectedSubHeaderId)
        instance.selectedCodes.set('keywordId', '')
        instance.addingCode.set('keyword', false)

    'click .delete-header-button': (event, instance) ->
      headerId = event.target.parentElement.getAttribute("data-header-id")
      instance.headerToDelete.set(Headers.findOne(headerId))

    'click .delete-subheader-button': (event, instance) ->
      subHeaderId = event.target.parentElement.getAttribute("data-subheader-id")
      instance.subHeaderToDelete.set(SubHeaders.findOne(subHeaderId))

    'click .add-code': (event, instance) ->
      level = $(event.target).data('level')
      instance.addingCode.set(level, not instance.addingCode.get(level))

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

      Meteor.call 'addHeader', headerProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Header added")
          form.header.value = ''
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
          toastr.success("Keyword added")
          form.keyword.value = ''
        form.keyword.focus()

    'click .delete-keyword-button': (event, instance) ->
      keywordId = event.target.parentElement.getAttribute("data-keyword-id")
      instance.keywordToDelete.set(CodingKeywords.findOne(keywordId))

  Template.new_header_form.onRendered ->
    @$("input").focus()

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
        color: 1 # TODO

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


if Meteor.isServer

  Meteor.publish 'Headers', ->
    if @userId
      Headers.find()
    else
      @ready()

  Meteor.publish 'subHeaders', (headerId) ->
    if @userId
      if headerId
        SubHeaders.find headerId: headerId
    else
      @ready()

  Meteor.publish 'Keywords', (subHeaderId) ->
    if @userId
      if subHeaderId
        CodingKeywords.find subHeaderId: subHeaderId
    else
      @ready()
