Annotations = new Mongo.Collection('annotations')
Annotation = Astro.Class
  name: 'Annotation'
  collection: Annotations
  transform: true
  fields:
    documentId: 'string'
    userId: 'string'
    codeId: 'string'
    startOffset: 'number'
    endOffset: 'number'

  methods:
    _codingKeyword: ->
      CodingKeywords.findOne(@codeId)
    header: ->
      @_codingKeyword()?.header
    subHeader: ->
      @_codingKeyword()?.subHeader
    keyword: ->
      @_codingKeyword()?.keyword
    color: ->
      @_codingKeyword()?.color

    overlapsWithOffsets: (startOffset, endOffset) ->
      (startOffset >= @startOffset and startOffset < @endOffset) or
      (endOffset > @startOffset and endOffset <= @endOffset) or
      (startOffset <= @startOffset and endOffset >= @endOffset)

    userEmail: ->
      Meteor.users.findOne(@userId)?.emails[0].address
