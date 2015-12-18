Documents = new Mongo.Collection('documents')
Document = Astro.Class
  name: 'Document'
  collection: Documents
  fields:
    title:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(5, 'The title must be at least 5 characters')
      ]
    lowerTitle: 
      type: 'string'
      transient: true
    body:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(20, 'The body must be at least 20 characters')
      ]
    groupId: 'string'
    group: 
      type: 'string'
      transient: true
    annotated:
      type: 'number'
      default: 0
    createdAt: 'date'
  behaviors: ['timestamp']

  events:
    afterInit: ->
      @set 'lowerTitle', @title.toLowerCase()
      @set 'group', Groups.findOne(@groupId)?.name.toLowerCase()

  methods:
    groupName: ->
      Groups.findOne(@groupId)?.name

    truncatedBody: ->
      splitText = @body?.split(' ')
      wordCount = 25
      if splitText?.length > wordCount
        splitText.slice(0,wordCount).join(' ')+'...'
      else
        @body

    textWithAnnotation: (annotation) ->
      body = @body
      startOffset = annotation.startOffset
      endOffset = annotation.endOffset

      if annotation.codeId
        color = annotation.color()
      else
        color = "temporary"

      preTagBody = body.slice(0, startOffset)
      openTag = "<span data-annotation-id='#{annotation._id}' class='annotation-highlight annotation-highlight-#{color}'>"
      annotatedText = body.slice(startOffset, endOffset)
      closeTag = "</span>"
      postTagBody = body.slice(endOffset, body.length)

      "#{preTagBody}#{openTag}#{annotatedText}#{closeTag}#{postTagBody}"
