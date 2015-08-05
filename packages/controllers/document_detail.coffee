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
      Annotations.find({documentId: @documentId})

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

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
        attributes['codeId'] = event.target.getAttribute('data-id')
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
