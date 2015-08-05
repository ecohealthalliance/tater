if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @subscribe('annotations', @data.documentId)
    @showAnnotationForm = new ReactiveVar(false)
    @startOffset = new ReactiveVar()
    @startParagraph = new ReactiveVar()
    @endOffset = new ReactiveVar()
    @endParagraph = new ReactiveVar()

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'annotations': ->
      Annotations.find({documentId: @documentId})

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

    'positionInformation': ->
      "#{@startParagraph}:#{@startOffset} - #{@endParagraph}:#{@endOffset}"

    'header': ->
      @header()

    'subHeader': ->
      @subHeader()

    'keyword': ->
      @keyword()

  Template.documentDetail.events
    'click .document-detail-container': (event, instance) =>
      instance.startOffset.set(null)
      instance.startParagraph.set(null)
      instance.endOffset.set(null)
      instance.endParagraph.set(null)

      selection = window.getSelection()
      range = selection.getRangeAt(0)

      if range
        startOffset = range.startOffset
        startParagraph = range.startContainer.parentElement.getAttribute('data-index')
        endOffset = range.endOffset
        endParagraph = range.endContainer.parentElement.getAttribute('data-index')

        instance.startOffset.set(startOffset)
        instance.startParagraph.set(startParagraph)
        instance.endOffset.set(endOffset)
        instance.endParagraph.set(endParagraph)

    'click .selectable-code': (event, instance) ->
      if instance.endOffset.get()
        attributes = {}
        attributes['codeId'] = event.target.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startOffset'] = instance.startOffset.get()
        attributes['endOffset'] = instance.endOffset.get()
        attributes['startParagraph'] = instance.startParagraph.get()
        attributes['endParagraph'] = instance.endParagraph.get()
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
