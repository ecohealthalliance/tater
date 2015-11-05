if Meteor.isClient
  Template.editCodingKeywords.onCreated ->
    @subscribe('codingKeywords', @data?.groupId)
    @keywordToDeleteId = new ReactiveVar()

  Template.editCodingKeywords.settings = () =>

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

  Template.editCodingKeywords.keywordCollection = () ->
    CodingKeywords.find()

  Template.editCodingKeywords.helpers
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
        color: 1
        groupId: instance.data?.groupId

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Keyword added")
        $('#remove-keyword-modal').modal('hide')
        instance.keywordToDeleteId.set(null)

if Meteor.isServer
  Meteor.methods
    addKeyword: (keywordProps) ->
      # Delete falsy values so the $exists queries work
      for prop of keywordProps
        unless keywordProps[prop]
          delete keywordProps[prop]
      if Meteor.users.findOne(@userId)?.admin
        if keywordProps.keyword or keywordProps.subHeader
          if not keywordProps.header
            throw new Meteor.Error('Header is required')
          if not CodingKeywords.findOne(
            header: keywordProps.header
            subHeader: { $exists: false }
            keyword: { $exists: false }
          ) then throw new Meteor.Error("""The header does not exist.
          Omit the keyword and sub-header fields to create it before adding the keyword.""")
        if keywordProps.keyword
          if not keywordProps.header
            throw new Meteor.Error('Header is required')
          if not keywordProps.subHeader
            throw new Meteor.Error('Sub-header is required')
          if not CodingKeywords.findOne(
            header: keywordProps.header
            subHeader: keywordProps.subHeader
            keyword: { $exists: false }
          ) then throw new Meteor.Error("""The sub-header does not exist.
          Omit the keyword field to create it before adding the keyword.""")
        if CodingKeywords.findOne(keywordProps)
          throw new Meteor.Error('Duplicate keyword')
        CodingKeywords.insert keywordProps
      else
        throw new Meteor.Error('Unauthorized')
