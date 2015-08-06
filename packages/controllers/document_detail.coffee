if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @subscribe('annotations', @data.documentId)
    @showAnnotationForm = new ReactiveVar(false)
    @startOffset = new ReactiveVar()
    @endOffset = new ReactiveVar()

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'annotations': ->
      Annotations.find({documentId: @documentId}, {sort: {startOffset: 1}})

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

    'annotatedText': ->
      annotations = Annotations.find({documentId: @documentId}, {sort: {startOffset: 1}}).fetch()
      body = Documents.findOne({ _id: @documentId }).body
      offsetShift = 0
      for annotation in annotations
        startOffset = annotation.startOffset + offsetShift
        endOffset = annotation.endOffset + offsetShift

        preTagBody = body.slice(0, startOffset)
        openTag = "<span class='annotation-color-#{annotation.color()}'>"
        annotatedText = body.slice(startOffset, endOffset)
        closeTag = "</span>"
        postTagBody = body.slice(endOffset, body.length)

        offsetShift = offsetShift + openTag.length + closeTag.length
        body = "#{preTagBody}#{openTag}#{annotatedText}#{closeTag}#{postTagBody}"

      paragraphs = body.split(/\r?\n\n/g)
      formattedBody = ""

      for paragraph in paragraphs
        formattedBody = "#{formattedBody}<p>#{paragraph}</p>"
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

if Meteor.isServer
  Meteor.publish 'documentDetail', (id) ->
    Documents.find id

  Meteor.publish 'annotations', (documentId) ->
    Annotations.find({documentId: documentId})

  Meteor.methods
    createAnnotation: (attributes) ->
      annotation = new Annotation()
      annotation.set(attributes)
      annotation.set(userId: @userId)
      annotation.save ->
        annotation
