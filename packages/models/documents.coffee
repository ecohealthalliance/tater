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
      openTag = "<span data-annotation-id='#{annotation._id}' class='annotation-highlight-#{color}'>"
      annotatedText = body.slice(startOffset, endOffset)
      closeTag = "</span>"
      postTagBody = body.slice(endOffset, body.length)

      "#{preTagBody}#{openTag}#{annotatedText}#{closeTag}#{postTagBody}"
