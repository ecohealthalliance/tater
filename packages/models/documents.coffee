Documents = new Mongo.Collection('documents')
Document = Astro.Class
  name: 'Document'
  collection: Documents
  fields:
    title:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(5, 'The title must be at least 5 characters long.')
      ]
    body:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(20, 'The body must be at least 20 characters long.')
      ]
    groupId: 'string'
    annotated:
      type: 'number'
      default: 0
    mTurkEnabled:
      type: 'boolean'
      default: false
    finishedAt:
      type: 'date'
    note: 'string'
    createdAt: 'date'
  behaviors: ['timestamp']

  events:
    beforeRemove: (event) ->
      if Meteor.isServer
        if not @removeAllRelatedMTurkJobs()
          event.preventDefault()
          throw new Meteor.Error 'failure', 'Failed to cancel all related HITs'

  methods:
    groupName: ->
      Groups.findOne(@groupId)?.name

    truncatedBody: ->
      splitText = @body?.split(' ')
      wordCount = 25
      if splitText?.length > wordCount
        splitText.slice(0, wordCount).join(' ')+'...'
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

    removeAllRelatedMTurkJobs: ->
      if Meteor.isServer
        ok = true
        totalHITsForThisDocument = 0
        cancelledHITs = 0
        mTurkJobs = MTurkJobs.find(documentId: @_id).forEach (job) ->
          totalHITsForThisDocument += 1
          if job.cancel()
            cancelledHITs += 1
        if cancelledHITs < totalHITsForThisDocument
          ok = false
        else
          @set(mTurkEnabled: false)
          @save()
        ok

    finish: ->
      if Meteor.isServer
        @set finishedAt: new Date()
        @save()
