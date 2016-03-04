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
    used:
      type: 'number'
      default: 0
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
    recountUsage: ->
      count = Annotations.find(codeId: @_id).count()
      @set('used', count)
      @save()
      count
