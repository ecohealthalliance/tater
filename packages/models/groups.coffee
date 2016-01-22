Groups = new Mongo.Collection('groups')
Group = Astro.Class
  name: 'Group'
  collection: Groups
  fields:
    name:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(5, 'The group name must be at least 5 characters')
      ]
    description: 'string'
    createdById: 'string'
  behaviors: ['timestamp']

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
