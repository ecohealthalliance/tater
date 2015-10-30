if Meteor.isClient
  Template.editCodingKeywords.onCreated ->
    @subscribe('codingKeywords')
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

    fields.push
      key: "controls"
      label: ""
      hideToggle: true
      fn: (val, obj) ->
        new Spacebars.SafeString("""
          <a class="control remove remove-keyword" data-id="#{obj._id}" title="Remove">
            <i class='fa fa-remove'></>
          </a>
        """)

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

      Meteor.call 'addKeyword', keywordProps, (error, response) ->
        if error
          toastr.error("Error: #{error.message}")
        else
          toastr.success("Keyword added")
        $('#remove-keyword-modal').modal('hide')
        instance.keywordToDeleteId.set(null)

    'click .remove-keyword': (event, instance) ->
      keywordId = $(event.currentTarget).data("id")
      instance.keywordToDeleteId.set(keywordId)
      $('#remove-keyword-modal').modal('show')

    'click .confirm-remove-keyword': (event, instance) ->
      keywordId = instance.keywordToDeleteId.get()
      Meteor.call 'removeKeyword', keywordId, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Keyword removed")
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
        if keywordProps.keyword
          if not keywordProps.header
            throw new Meteor.Error('Header is required')
          if not keywordProps.subHeader
            throw new Meteor.Error('Sub-header is required')
        if CodingKeywords.findOne(keywordProps)
          throw new Meteor.Error('Duplicate keyword')
        CodingKeywords.insert keywordProps
      else
        throw new Meteor.Error('Unauthorized')
    removeKeyword: (keywordId) ->
      if Meteor.users.findOne(@userId)?.admin
        CodingKeywords.remove keywordId
      else
        throw new Meteor.Error('Unauthorized')
