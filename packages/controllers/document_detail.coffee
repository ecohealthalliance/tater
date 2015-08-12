if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @subscribe('annotations', @data.documentId)
    @subscribe('users', @data.documentId)
    @showAnnotationForm = new ReactiveVar(false)
    @annotations = new ReactiveVar()
    @searchText = new ReactiveVar('')
    @temporaryAnnotation = new ReactiveVar(new Annotation())
    @overlappingSelection = new ReactiveVar(false)

  Template.documentDetail.onRendered ->
    instance = Template.instance()
    @autorun ->
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

    'annotationUserEmail': ->
      @userEmail()

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

    'annotatedText': ->
      temporaryAnnotation = Template.instance().temporaryAnnotation.get()
      annotations = Annotations.find({documentId: @documentId}).fetch()
      if temporaryAnnotation.startOffset
        annotations.push(temporaryAnnotation)
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

    'overlappingSelection': ->
      Template.instance().overlappingSelection.get()

  Template.documentDetail.events
    'mousedown .document-container': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      temporaryAnnotation.set({startOffset: null, endOffset: null})
      instance.temporaryAnnotation.set(temporaryAnnotation)

    'click .document-container': (event, instance) =>
      temporaryAnnotation = instance.temporaryAnnotation.get()

      selection = window.getSelection()
      range = selection.getRangeAt(0)
      selectionInDocument = selection.anchorNode.parentElement.getAttribute('class') == 'document-text'
      textHighlighted = range and (range.endOffset > range.startOffset)

      if selectionInDocument and textHighlighted
        overlapping = _.find instance.annotations.get().fetch(), (annotation) ->
          annotation.overlapsWithOffsets(range.startOffset, range.endOffset)

        if !overlapping
          instance.overlappingSelection.set(false)

          startOffset = range.startOffset
          endOffset = range.endOffset

          temporaryAnnotation.set({startOffset: startOffset, endOffset: endOffset})
          instance.temporaryAnnotation.set(temporaryAnnotation)

        else
          instance.overlappingSelection.set(true)

      else
        instance.overlappingSelection.set(false)

    'click .selectable-code': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      if temporaryAnnotation.startOffset
        attributes = {}
        attributes['codeId'] = event.currentTarget.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startOffset'] = temporaryAnnotation.startOffset
        attributes['endOffset'] = temporaryAnnotation.endOffset
        Meteor.call('createAnnotation', attributes)

        temporaryAnnotation.set({startOffset: null, endOffset: null})
        instance.temporaryAnnotation.set(temporaryAnnotation)

    'keyup .annotation-search': _.debounce ((e, instance) -> instance.searchText.set e.target.value), 200

    'click .delete-annotation': (event, instance) ->
      annotationId = event.currentTarget.getAttribute('data-annotation-id')
      $(event.currentTarget).parent().addClass('deleting')
      setTimeout (-> Meteor.call 'deleteAnnotation', annotationId), 800

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

  Meteor.publish 'users', (documentId) ->
    document = Documents.findOne(documentId)
    group = Groups.findOne({_id: document.groupId})
    Meteor.users.find
      group: group._id
      fields:
        emails: 1

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

    deleteAnnotation: (annotationId) ->
      annotation = Annotations.findOne(annotationId)
      document = Documents.findOne(annotation.documentId)
      if @userId
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        if group?.viewableByUserWithGroup(user.group)
          annotation.remove() ->
            annotation
        else
          throw 'Unauthorized'
      else
        throw 'Unauthorized'
