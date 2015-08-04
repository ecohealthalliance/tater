if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @subscribe('annotations', @data.documentId)
    @showAnnotationForm = new ReactiveVar(false)
    @startIndex = new ReactiveVar()
    @endIndex = new ReactiveVar()

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'annotations': ->
      Annotations.find({documentId: @documentId})

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

    'header': ->
      @header()

    'subHeader': ->
      @subHeader()

    'keyword': ->
      @keyword()

  Template.documentDetail.events
    'click .document-detail-container': (event, instance) =>
      instance.startIndex.set(null)
      instance.endIndex.set(null)

      selection = window.getSelection()

      range = selection.getRangeAt(0)
      start = range.startOffset
      end = range.endOffset

      if end > start
        instance.startIndex.set(start)
        instance.endIndex.set(end)

    'click .selectable-code': (event, instance) ->
      if instance.endIndex.get()
        attributes = {}
        attributes['codeId'] = event.target.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startIndex'] = instance.startIndex.get()
        attributes['endIndex'] = instance.endIndex.get()
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
