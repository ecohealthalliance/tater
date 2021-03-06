if Meteor.isClient

  Template.codingKeywords.onCreated ->
    @selectedCodes = new ReactiveDict()
    @addingCode = new ReactiveDict()
    @keywordToDelete = new ReactiveVar()
    @subHeaderToDelete = new ReactiveVar()
    @headerToDelete = new ReactiveVar()
    @codeColor = new ReactiveVar ''
    @headersLoading = new ReactiveVar true
    @subHeadersLoading = new ReactiveVar false
    @keywordsLoading = new ReactiveVar false
    @archiving = new ReactiveVar false

  Template.codingKeywords.onRendered ->
    instance = Template.instance()
    @subscribe 'headers', ->
      instance.addingCode.set('header', Headers.find().fetch().length == 0)
      instance.headersLoading.set(false)
    @autorun ->
      selectedHeaderId = instance.selectedCodes.get('headerId')
      if selectedHeaderId
        instance.subHeadersLoading.set(true)
        Meteor.subscribe 'subHeaders', selectedHeaderId, ->
          instance.subHeadersLoading.set(false)
          if SubHeaders.findOne({ headerId: selectedHeaderId})
            instance.addingCode.set('subHeader', false)
          else
            instance.addingCode.set('subHeader', true)

    @autorun ->
      selectedSubHeaderId = instance.selectedCodes.get('subHeaderId')
      if selectedSubHeaderId
        instance.keywordsLoading.set(true)
        Meteor.subscribe 'keywords', selectedSubHeaderId, ->
          instance.keywordsLoading.set(false)
          if CodingKeywords.findOne({ subHeaderId: selectedSubHeaderId})
            instance.addingCode.set('keyword', false)
          else
            instance.addingCode.set('keyword', true)

  Template.codingKeywords.helpers
    headers: ->
      Headers.find({}, {sort: {archived: 1}})

    subHeaders: ->
      selectedHeaderId = Template.instance().selectedCodes.get('headerId')
      SubHeaders.find({headerId: selectedHeaderId}, {sort: {archived: 1}})

    keywords: ->
      selectedSubHeaderId = Template.instance().selectedCodes.get('subHeaderId')
      CodingKeywords.find({subHeaderId: selectedSubHeaderId}, {sort: {archived: 1}})

    selected: (level) ->
      if level == 'header'
        if @_id == Template.instance().selectedCodes.get('headerId')
          'selected'
      else
        if @_id == Template.instance().selectedCodes.get('subHeaderId')
          'selected'

    unarchived: ->
      !@archived

    restorable: ->
      header = Headers.findOne(Template.instance().selectedCodes.get('headerId'))
      subHeader = SubHeaders.findOne(Template.instance().selectedCodes.get('subHeaderId'))
      @archived && !header.archived && !subHeader.archived

    selectedCodes: ->
      Template.instance().selectedCodes

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

    codeColor: ->
      Template.instance().codeColor

    headersLoading: ->
      Template.instance().headersLoading.get()

    subHeadersLoading: ->
      Template.instance().subHeadersLoading.get() or Template.instance().archiving.get()

    keywordsLoading: ->
      Template.instance().keywordsLoading.get() or Template.instance().archiving.get()

  Template.codingKeywords.events
    'click .code-level-1': (event, instance) ->
      selectedHeaderId = event.currentTarget.getAttribute('data-id')
      if selectedHeaderId != instance.selectedCodes.get('headerId')
        instance.selectedCodes.set('headerId', selectedHeaderId)
        instance.selectedCodes.set('subHeaderId', null)
        instance.selectedCodes.set('keywordId', null)
        instance.addingCode.set('keyword', false)
        instance.addingCode.set('subHeader', false)
        subHeaders = SubHeaders.find({headerId: selectedHeaderId},{sort: {archived: 1}})

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

    'click .delete-keyword-button': (event, instance) ->
      keywordId = event.target.parentElement.getAttribute("data-keyword-id")
      instance.keywordToDelete.set(CodingKeywords.findOne(keywordId))

    'click .unarchive-keyword-button': (event, instance) ->
      keywordId = event.target.parentElement.getAttribute("data-keyword-id")
      instance.archiving.set true
      Meteor.call 'unarchiveKeyword', keywordId, (error, response) ->
        if error
          ErrorHelpers.handleError error
          instance.archiving.set false
        else
          toastr.success("Keyword restored")
          instance.archiving.set false

    'click .unarchive-subheader-button': (event, instance) ->
      subHeaderId = event.target.parentElement.getAttribute("data-subheader-id")
      instance.archiving.set true
      Meteor.call 'unarchiveSubHeader', subHeaderId, (error, response) ->
        if error
          ErrorHelpers.handleError error
          instance.archiving.set false
        else
          toastr.success("Sub-Header restored")
          instance.archiving.set false

    'click .unarchive-header-button': (event, instance) ->
      headerId = event.target.parentElement.getAttribute("data-header-id")
      instance.archiving.set true
      Meteor.call 'unarchiveHeader', headerId, (error, response) ->
        if error
          ErrorHelpers.handleError error
          instance.archiving.set false
        else
          toastr.success("Header restored")
          instance.archiving.set false

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
        color: instance.codeColor?.get()

      Meteor.call 'addHeader', headerProps, (error, response) ->
        if error
          ErrorHelpers.handleError error
        else
          toastr.success("Header added")
          form.reset()
          instance.codeColor?.set('')
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
          ErrorHelpers.handleError error
        else
          toastr.success("Sub-Header added")
          form.subHeader.value = ''
          instance.addingCode.set('subHeader', true)
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
          ErrorHelpers.handleError error
        else
          toastr.success("Keyword added")
          instance.addingCode.set('keyword', true)
          form.keyword.value = ''
        form.keyword.focus()

  Template.newHeaderForm.onCreated ->
    @codeColor = Template.instance().data.codeColor

  Template.newHeaderForm.onRendered ->
    @$("input[name=header]").focus()

  Template.newHeaderForm.helpers
    selectedColor: (color) ->
      if color == Template.instance().codeColor.get()
        'selected'

    availableHeaderColors: ->
      [1,2,3,4,5,6,7,8]

  Template.newHeaderForm.events
    'click .header-colors li': (event, instance) ->
      instance.codeColor.set($(event.currentTarget).data('color'))

  Template.newSubheaderForm.onRendered ->
    @$("input").focus()

  Template.newKeywordForm.onRendered ->
    @$("input").focus()

_validateHeader = (headerId) ->
  if not Headers.findOne(headerId)
    throw new Meteor.Error 'invalid', """The header does not exist.
  Omit the keyword and sub-header fields to create it before adding the keyword."""

_validateSubheader = (headerId, subHeaderId) ->
  if not SubHeaders.findOne(
    _id: subHeaderId
    headerId: headerId
  ) then throw new Meteor.Error 'invalid', """The sub-header does not belong to the
  given header or does not exist."""

_validateKeywordProperties = (keywordProps) ->
  if not keywordProps.label
    throw new Meteor.Error 'empty', 'Keyword is empty'
  if not keywordProps.headerId
    throw new Meteor.Error 'required', 'Header is required'
  if not keywordProps.subHeaderId
    throw new Meteor.Error 'required', 'Sub-header is required'

  _validateHeader(keywordProps.headerId)
  _validateSubheader(keywordProps.headerId, keywordProps.subHeaderId)

  if CodingKeywords.findOne(
    headerId: keywordProps.headerId
    subHeaderId: keywordProps.subHeaderId
    label: keywordProps.label
  ) then throw new Meteor.Error 'duplicate keyword', 'Coding keyword already exiits'

  true

_validateSubHeaderProperties = (subHeaderProps) ->
  if not subHeaderProps.label
    throw new Meteor.Error 'empty', 'Sub-Header is empty'
  if not subHeaderProps.headerId
    throw new Meteor.Error 'required', 'Header is required'

  _validateHeader(subHeaderProps.headerId)

  if SubHeaders.findOne(
    headerId: subHeaderProps.headerId
    label: subHeaderProps.label
  ) then throw new Meteor.Error 'duplicate', 'Duplicate sub-header'

  true

_validateHeaderProperties = (headerProps) ->
  if not headerProps.label
    throw new Meteor.Error 'empty', 'Header is empty'
  if not headerProps.color
    throw new Meteor.Error 'undefined', 'Header color has not been chosen'

  if Headers.findOne(
    label: headerProps.label
  ) then throw new Meteor.Error 'duplicate', 'Duplicate header'

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
      throw new Meteor.Error 'unauthorized', 'You are not authorized to add headers'

  addSubHeader: (subHeaderProps) ->
    if Meteor.users.findOne(@userId)?.admin
      _subHeaderProps =
        headerId: subHeaderProps.headerId
        label: subHeaderProps.label?.trim()

      if _validateSubHeaderProperties(_subHeaderProps)
        SubHeaders.insert _subHeaderProps
    else
      throw new Meteor.Error 'unauthorized', 'You are not authorized to add sub-headers'

  addKeyword: (keywordProps) ->
    if Meteor.users.findOne(@userId)?.admin
      _keywordProps =
        headerId: keywordProps.headerId
        subHeaderId: keywordProps.subHeaderId
        label: keywordProps.label?.trim()

      if _validateKeywordProperties(_keywordProps)
        CodingKeywords.insert _keywordProps
    else
      throw new Meteor.Error 'unauthorized', 'You are not authorized to add coding keywords'

  unarchiveKeyword: (keywordId) ->
    if Meteor.users.findOne(@userId)?.admin
      keyword = CodingKeywords.findOne(keywordId)
      keyword.unarchive()
    else
      throw new Meteor.Error 'unauthorized', 'You are not authorized to unarchive headers'

  unarchiveSubHeader: (subHeaderId) ->
    if Meteor.users.findOne(@userId)?.admin
      subHeader = SubHeaders.findOne(subHeaderId)
      subHeader.unarchive()
    else
      throw new Meteor.Error 'unauthorized', 'You are not authorized to unarchive sub-headers'

  unarchiveHeader: (headerId) ->
    if Meteor.users.findOne(@userId)?.admin
      header = Headers.findOne(headerId)
      header.unarchive()
    else
      throw new Meteor.Error 'unauthorized', 'You are not authorized to unarchive headers'

if Meteor.isServer

  Meteor.publish 'headers', ->
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

  Meteor.publish 'keywords', (subHeaderId) ->
    if @userId
      if subHeaderId
        CodingKeywords.find subHeaderId: subHeaderId
    else
      @ready()
