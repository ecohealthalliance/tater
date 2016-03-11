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
    used: ->
      i = 0
      @codingKeywords().forEach (codingKeyword)->
        if codingKeyword?.used()
          i++
      i

    archive: ->
      codingKeywords = @codingKeywords()
      if codingKeywords.count()
        codingKeywords.forEach (codingKeyword)->
          codingKeyword?.archive()
        if @used()
          @set archived: true
          @save()
        else
          @remove()
      else
        @remove()

    unarchive: ->
      @set archived: false
      @save()
      @codingKeywords().forEach (codingKeyword)->
        codingKeyword?.unarchive()
