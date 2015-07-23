Groups = new Mongo.Collection('groups')
Group = Astro.Class
  name: 'Group'
  collection: Groups
  transform: true
  fields:
    name: 'string'
    description: 'string'
    createdById: 'string'

  methods:
    truncateDescription: ->
      splitDescription = @description?.split(' ')
      wordCount = 50
      if splitDescription.length > wordCount
        splitDescription.slice(0,wordCount).join(' ')+'...'
      else
        @description

    editableByUserWithGroup: (group) ->
      group == 'admin' || group == @_id

    documents: ->
      Documents.find({groupId: @_id})
