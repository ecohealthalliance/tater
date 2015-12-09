if Meteor.isClient

  Template.codingKeywords.onCreated ->
    @selectedCodes = new ReactiveDict()
    @addingCode = new ReactiveDict()
    @keywordToDelete = new ReactiveVar()
    @subHeaderToDelete = new ReactiveVar()
    @headerToDelete = new ReactiveVar()
    @codeColor = new ReactiveVar('')
    @headersLoading = new ReactiveVar(true)
    @subHeadersLoading = new ReactiveVar(true)
    @keywordsLoading = new ReactiveVar(false)

  Template.codingKeywords.onRendered ->
    instance = Template.instance()
    @subscribe 'headers', ->
      instance.addingCode.set('header', Headers.find().fetch().length == 0)
      instance.headersLoading.set(false)
    @autorun ->
      selectedHeaderId = instance.selectedCodes.get('headerId')
      Meteor.subscribe 'subHeaders', selectedHeaderId, ->
        instance.subHeadersLoading.set(false)
        if SubHeaders.findOne({ headerId: selectedHeaderId})
          instance.addingCode.set('subHeader', false)
        else
          instance.addingCode.set('subHeader', true)

    @autorun ->
      selectedSubHeaderId = instance.selectedCodes.get('subHeaderId')
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
      Template.instance().subHeadersLoading.get()

    keywordsLoading: ->
      Template.instance().keywordsLoading.get()

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
      Meteor.call 'unarchiveKeyword', keywordId, (error, instance) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Keyword restored")

    'click .unarchive-subheader-button': (event, instance) ->
      subHeaderId = event.target.parentElement.getAttribute("data-subheader-id")
      Meteor.call 'unarchiveSubHeader', subHeaderId, (error, instance) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Sub-Header restored")

    'click .unarchive-header-button': (event, instance) ->
      headerId = event.target.parentElement.getAttribute("data-header-id")
      Meteor.call 'unarchiveHeader', headerId, (error, instance) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Header restored")

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
          toastr.error("Error: #{error.message}")
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
          toastr.error("Error: #{error.message}")
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
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Keyword added")
          instance.addingCode.set('keyword', true)
          form.keyword.value = ''
        form.keyword.focus()

  Template.new_header_form.onCreated ->
    @codeColor = Template.instance().data.codeColor

  Template.new_header_form.onRendered ->
    @$("input[name=header]").focus()

  Template.new_header_form.helpers
    selectedColor: (color) ->
      if color == Template.instance().codeColor.get()
        'selected'

    availableHeaderColors: ->
      [1,2,3,4,5,6,7,8]

  Template.new_header_form.events
    'click .header-colors li': (event, instance) ->
      instance.codeColor.set($(event.currentTarget).data('color'))

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
  if not headerProps.color
    throw new Meteor.Error('Header color has not been chosen')

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

  unarchiveKeyword: (keywordId) ->
    if Meteor.users.findOne(@userId)?.admin
      CodingKeywords.update keywordId,
        $set: 
          archived: false
    else
      throw new Meteor.Error('Unauthorized')

  unarchiveSubHeader: (subHeaderId) ->
    if Meteor.users.findOne(@userId)?.admin
      SubHeaders.update subHeaderId,
        $set: 
          archived: false
      CodingKeywords.update {subHeaderId: subHeaderId},
        {
          $set:
            archived: false
        },
        {multi: true}
    else
      throw new Meteor.Error('Unauthorized')

  unarchiveHeader: (headerId) ->
    if Meteor.users.findOne(@userId)?.admin
      Headers.update headerId,
        $set:
          archived: false
      SubHeaders.update {headerId: headerId},
        {
          $set:
            archived: false
        },
        {multi: true}
      CodingKeywords.update {
          # The headerId property is undefined in some cases
          # so for now we're using the subHeaderIds
          subHeaderId:
            $in: SubHeaders.find(headerId: headerId).map (x)-> x._id
        },
        {
          $set:
            archived: false
        },
        {multi: true}
    else
      throw new Meteor.Error('Unauthorized')

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
