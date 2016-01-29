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
