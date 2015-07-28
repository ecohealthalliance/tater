Documents = new Mongo.Collection('documents')
Document = Astro.Class
  name: 'Document'
  collection: Documents
  transform: true
  fields:
    title: 'string'
    body: 'string'
    groupId: 'string'

  methods:
    truncatedBody: ->
      splitText = @body?.split(' ')
      wordCount = 25
      if splitText?.length > wordCount
        splitText.slice(0,wordCount).join(' ')+'...'
      else
        @body
