if Meteor.isClient
  Template.editCodingKeywords.onCreated ->
    @subscribe('codingKeywords')
    @keywordToDeleteId = new ReactiveVar()

  Template.editCodingKeywords.helpers
    settings: =>
      fields = []
      fields.push
        key: 'header'
        label: 'Header'
      fields.push
        key: 'subHeader'
        label: 'Sub-Header'
      fields.push
        key: 'keyword'
        label: 'Keyword'
      showColumnToggles: false
      showFilter: true
      showRowCount: true
      fields: fields

    keywordCollection: ->
      CodingKeywords.find()

    keywordToDelete: ->
      CodingKeywords.findOne(Template.instance().keywordToDeleteId.get())

  Template.editCodingKeywords.events
    'submit form': (event, instance) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      keywordProps =
        header: form.header.value
        subHeader: form.subHeader.value
        keyword: form.keyword.value

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Keyword added")
        $('#remove-keyword-modal').modal('hide')
        instance.keywordToDeleteId.set(null)

###
if Meteor.isServer

  _validateHeader = (header) ->
    if not CodingKeywords.findOne(
      header: header
      subHeader: { $exists: false }
      keyword: { $exists: false }
    ) then throw new Meteor.Error("""The header does not exist.
    Omit the keyword and sub-header fields to create it before adding the keyword.""")

  _validateSubheader = (header, subHeader) ->
    if not CodingKeywords.findOne(
      header: header
      subHeader: subHeader
      keyword: { $exists: false }
    ) then throw new Meteor.Error("""The sub-header does not exist.
    Omit the keyword field to create it before adding the keyword.""")

  _validateKeywordProperties = (keywordProps) ->
    if CodingKeywords.findOne(keywordProps)
      throw new Meteor.Error('Duplicate keyword')

    if keywordProps.keyword or keywordProps.subHeader
      if not keywordProps.header
        throw new Meteor.Error('Header is required')

      _validateHeader(keywordProps.header)

    if keywordProps.keyword
      if not keywordProps.subHeader
        throw new Meteor.Error('Sub-header is required')

      _validateSubheader(keywordProps.header, keywordProps.subHeader)

    true

  Meteor.methods
    addKeyword: (keywordProps) ->
      # Delete falsy values so the $exists queries work
      for prop of keywordProps
        unless keywordProps[prop]
          delete keywordProps[prop]
      if Meteor.users.findOne(@userId)?.admin
        if _validateKeywordProperties(keywordProps)
          color = CodingKeywords.findOne({header: keywordProps.header})?.color
          keywordProps.color = color or 1
          CodingKeywords.insert keywordProps
      else
        throw new Meteor.Error('Unauthorized')
###
