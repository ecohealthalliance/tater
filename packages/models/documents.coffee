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

    textWithAnnotations: (annotations) ->
      offsetShift = 0
      body = @body
      annotations = _.sortBy(annotations, 'startOffset')
      for annotation in annotations
        startOffset = annotation.startOffset + offsetShift
        endOffset = annotation.endOffset + offsetShift

        if annotation.codeId
          color = annotation.color()
        else
          color = "temporary"

        preTagBody = body.slice(0, startOffset)
        openTag = "<span data-annotation-id='#{annotation._id}' class='annotation-highlight-#{color}'>"
        annotatedText = body.slice(startOffset, endOffset)
        closeTag = "</span>"
        postTagBody = body.slice(endOffset, body.length)

        offsetShift = offsetShift + openTag.length + closeTag.length
        body = "#{preTagBody}#{openTag}#{annotatedText}#{closeTag}#{postTagBody}"
      body
