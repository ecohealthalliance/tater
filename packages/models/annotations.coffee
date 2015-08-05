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
      @_codingKeyword().header
    subHeader: ->
      @_codingKeyword().subHeader
    keyword: ->
      @_codingKeyword().keyword
    color: ->
      @_codingKeyword().color
