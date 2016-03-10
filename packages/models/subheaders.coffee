SubHeaders = new Mongo.Collection('subHeaders')
SubHeaders = Astro.Class
  name: 'SubHeaders'
  collection: SubHeaders
  fields:
    headerId: 'string'
    label: 'string'
    archived: 'boolean'
  behaviors: ['timestamp']
  methods:
    codingKeywords: ->
      CodingKeywords.find subHeaderId: @_id

    archive: ->
      codingKeywords = @codingKeywords()
      if codingKeywords.count()
        @set archived: true
        @save()
        codingKeywords.forEach (codingKeyword)->
          codingKeyword.archive()
      else
        @remove()

    unarchive: ->
      @set archived: false
      @save()
      @codingKeywords().forEach (codingKeyword)->
        codingKeyword.unarchive()
