Annotations = new Mongo.Collection('annotations')
Annotation = Astro.Class
  name: 'Annotation'
  collection: Annotations
  fields:
    documentId: 'string'
    userId: 'string'
    codeId:
      type: 'string'
      validator: Validators.required()
    startOffset: 'number'
    endOffset: 'number'
    userToken: 'string'
    flagged: 'boolean'
  behaviors: ['timestamp']

  events:
    afterSave: () ->
      @setDocumentCounts()
    afterRemove: () ->
      @setDocumentCounts()

  methods:
    _codingKeyword: ->
      CodingKeywords.findOne(@codeId)
    header: ->
      @_codingKeyword()?.headerLabel()
    subHeader: ->
      @_codingKeyword()?.subHeaderLabel()
    keyword: ->
      @_codingKeyword()?.label
    color: ->
      @_codingKeyword()?.color()

    setDocumentCounts: ->
      annoCount = Annotations.find({documentId: @documentId}).count()
      Documents.update({_id: @documentId}, {$set: {annotated: annoCount}})

    overlapsWithOffsets: (startOffset, endOffset) ->
      (startOffset >= @startOffset and startOffset < @endOffset) or
      (endOffset > @startOffset and endOffset <= @endOffset) or
      (startOffset <= @startOffset and endOffset >= @endOffset)

    userEmail: ->
      Meteor.users.findOne(@userId)?.emails[0].address

    document: ->
      Documents.findOne({_id: @documentId})

    text: ->
      Spacebars.SafeString @document().body.substring(@startOffset, @endOffset)
