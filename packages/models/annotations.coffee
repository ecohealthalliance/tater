Annotations = new Mongo.Collection('annotations')
Annotation = Astro.Class
  name: 'Annotation'
  collection: Annotations
  transform: true
  fields:
    documentId: 'string'
    userId: 'string'
    codeId: 'string'
    startIndex: 'number'
    endIndex: 'number'

  methods:
    _codingKeyword: ->
      CodingKeywords.findOne(@codeId)
    header: ->
      @_codingKeyword().header
    subHeader: ->
      @_codingKeyword().subHeader
    keyword: ->
      @_codingKeyword().keyword
