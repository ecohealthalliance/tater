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
    archive: ->
      used = Annotations.findOne codeId: @_id
      if used
        @set archived: true
        @save()
      else
        @remove()
    unarchive: ->
      @set archived: false
      @save()
