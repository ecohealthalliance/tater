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

    archive: ->
      subHeaders = @subHeaders()
      if subHeaders
        @set archived: true
        @save()
        subHeaders.forEach (subHeader)->
          subHeader.archive()
      else
        @remove()

    unarchive: ->
      @set archived: false
      @save()
      subHeaders = @subHeaders()
      subHeaders.forEach (subHeader)->
        subHeader.unarchive()
