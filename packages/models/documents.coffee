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

    textWithAnnotations: (annotations) ->
      offsetShift = 0
      body = @body
      for annotation in annotations
        startOffset = annotation.startOffset + offsetShift
        endOffset = annotation.endOffset + offsetShift

        preTagBody = body.slice(0, startOffset)
        openTag = "<span class='annotation-highlight-#{annotation.color()}'>"
        annotatedText = body.slice(startOffset, endOffset)
        closeTag = "</span>"
        postTagBody = body.slice(endOffset, body.length)

        offsetShift = offsetShift + openTag.length + closeTag.length
        body = "#{preTagBody}#{openTag}#{annotatedText}#{closeTag}#{postTagBody}"
      body
