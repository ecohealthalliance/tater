if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @subscribe('annotations', @data.documentId)
    @showAnnotationForm = new ReactiveVar(false)
    @startOffset = new ReactiveVar()
    @endOffset = new ReactiveVar()
    @annotations = new ReactiveVar()
    @searchText = new ReactiveVar('')

  Template.documentDetail.onRendered ->
    instance = Template.instance()
    @autorun ->
      if FlowRouter.subsReady()
        annotations = Annotations.find({documentId: instance.data.documentId})
        if instance.searchText.get() is ''
          instance.annotations.set annotations
        else
          searchText = instance.searchText.get().split(' ')
          filteredAnnotations = _.filter annotations.fetch(), (annotation) ->
            code = CodingKeywords.findOne(annotation.codeId)
            wordMatches = _.filter searchText, (word) ->
              word = new RegExp(word, 'i')
              code.header?.match(word) or code.subHeader?.match(word) or code.keyword?.match(word)
            wordMatches.length
          instance.annotations.set _.sortBy filteredAnnotations, 'startOffset'

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'annotations': ->
      Template.instance().annotations.get()

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

    'annotatedText': ->
      annotations = Annotations.find({documentId: @documentId}, {sort: {startOffset: 1}}).fetch()
      document = Documents.findOne({ _id: @documentId })
      annotatedBody = document.textWithAnnotations(annotations)
      paragraphs = annotatedBody.split(/\r?\n\n/g)

      for paragraph in paragraphs
        if formattedBody
          formattedBody = "#{formattedBody}<br><br>#{paragraph}"
        else
          formattedBody = paragraph
      Spacebars.SafeString(formattedBody)

    'positionInformation': ->
      "#{@startOffset} - #{@endOffset}"

    'header': ->
      @header()

    'subHeader': ->
      @subHeader()

    'keyword': ->
      @keyword()

    'color': ->
      @color()

  Template.documentDetail.events
    'mousedown .coding-container i': (event) ->
      event.preventDefault()

    'click .document-detail-container': (event, instance) =>
      instance.startOffset.set(null)
      instance.endOffset.set(null)

      selection = window.getSelection()
      range = selection.getRangeAt(0)
      textSelected = selection.anchorNode.parentElement.getAttribute('class') == 'document-text'
      textHighlighted = range and (range.endOffset > range.startOffset)

      if textSelected and textHighlighted
        startOffset = range.startOffset
        endOffset = range.endOffset

        instance.startOffset.set(startOffset)
        instance.endOffset.set(endOffset)

    'click .selectable-code': (event, instance) ->
      if instance.endOffset.get()
        attributes = {}
        attributes['codeId'] = event.currentTarget.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startOffset'] = instance.startOffset.get()
        attributes['endOffset'] = instance.endOffset.get()
        Meteor.call('createAnnotation', attributes)

    'keyup .annotation-search': _.debounce (e, templateInstance) ->
      templateInstance.searchText.set e.target.value

if Meteor.isServer
  Meteor.publish 'documentDetail', (id) ->
    document = Documents.findOne(id)
    if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUserWithGroup(user.group)
        Documents.find id
      else
        @ready()
    else
      @ready()

  Meteor.publish 'annotations', (documentId) ->
    document = Documents.findOne(documentId)
    if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUserWithGroup(user.group)
        Annotations.find({documentId: documentId})
      else
        @ready()
    else
      @ready()

  Meteor.methods
    createAnnotation: (attributes) ->
      document = Documents.findOne(attributes.documentId)
      if @userId
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        if group?.viewableByUserWithGroup(user.group)
          annotation = new Annotation()
          annotation.set(attributes)
          annotation.set(userId: @userId)
          annotation.save ->
            annotation
        else
          throw 'Unauthorized'
      else
        throw 'Unauthorized'
