Headers = new Mongo.Collection('headers')
Headers = Astro.Class
  name: 'Headers'
  collection: Headers
  fields:
    color: 'number'
    label: 'string'
    archived: 'boolean'
  behaviors: ['timestamp']
  methods:
    subHeaders: ->
      SubHeaders.find(headerId: @_id)

    used: ->
      i = 0
      @subHeaders().forEach (subHeader)->
        if subHeader?.used()
          i++
      i

    archive: ->
      subHeaders = @subHeaders()
      if subHeaders
        @set archived: true
        @save()
        subHeaders.forEach (subHeader)->
          subHeader?.archive()
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
      subHeaders = @subHeaders()
      subHeaders.forEach (subHeader)->
        subHeader?.unarchive()
