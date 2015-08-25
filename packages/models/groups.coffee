Groups = new Mongo.Collection('groups')
Group = Astro.Class
  name: 'Group'
  collection: Groups
  transform: true
  fields:
    name: 'string'
    description: 'string'
    createdById: 'string'
    codeAccessible: 'boolean'

  methods:
    truncateDescription: ->
      splitDescription = @description?.split(' ')
      wordCount = 50
      if splitDescription.length > wordCount
        splitDescription.slice(0,wordCount).join(' ')+'...'
      else
        @description

    viewableByUser: (user) ->
      user.admin or (user.group is @_id)

    documents: ->
      Documents.find({groupId: @_id})
