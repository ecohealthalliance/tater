CodingKeywords = new Mongo.Collection('keywords')
CodingKeyword = Astro.Class
  name: 'CodingKeyword'
  collection: CodingKeywords
  fields:
    headerId: 'string'
    subHeaderId: 'string'
    label: 'string'
    caseCount: 'boolean'
    archived: 'boolean'
  behaviors: ['timestamp']
  methods:
    _subHeader: ->
      SubHeaders.findOne(@subHeaderId)
    _header: ->
      Headers.findOne(@_subHeader().headerId)
    color: ->
      @_header().color
    headerLabel: ->
      @_header().label
    subHeaderLabel: ->
      @_subHeader().label
    used: ->
      Annotations.findOne codeId: @_id
    archive: ->
      if @used()
        @set archived: true
        @save()
        @documents().forEach (document)->
          document?.updateAnnotationCount()
      else
        @remove()
    unarchive: ->
      @set archived: false
      @save()
      @documents().forEach (document)->
        document?.updateAnnotationCount()
    documents: ->
      annotations = Annotations.find(codeId: @_id).fetch()
      documentIds = _.unique _.pluck annotations, 'documentId'
      Documents.find {_id: {$in: documentIds}}
