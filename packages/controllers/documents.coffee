if Meteor.isClient
  Template.documents.onCreated ->
    @subscribe('documents')
    @subscribe('groups')
    @subscribe('codingKeywords')    
    @selectedCodes  = new Meteor.Collection(null);
    
  Template.documents.onRendered ->
    instance = Template.instance()
    
    #Subscribe dynamically to annotation collection items that reference selected codeIds 
    @autorun ->
      selectedCodes = instance.selectedCodes.find().fetch()
      _.each selectedCodes, (codeKeywordResult) ->
        instance.subscribe('annotationsWithCodeId', codeKeywordResult.codeKeyword._id )

  Template.documents.helpers

    documents: -> 
      Documents.find({}, {groupId: @groupId})

    groupName: ->
      @groupName()

    selectedCodes: ->
      selectedCodes = Template.instance().selectedCodes.find()
     
    docsWithCodeId: (codeKeyword) ->
      docsFound = []

      colAnnotations = Annotations.find({codeId: codeKeyword._id }).fetch(); 
      
      #All documents with annotation keywords we are (dynamically) subscribed too
      uniqueDocsWithAnnotations = _.unique _.pluck(colAnnotations, 'documentId')

      #Only show the document if it actually has an annotation with this codeID associated with it
      _.each uniqueDocsWithAnnotations, (uniqueDocId) ->
        docFound  = Documents.findOne { _id: uniqueDocId }

        #annotations on this document with the current selected codeId
        annosFound = Annotations.find({documentId: uniqueDocId, codeId: codeKeyword._id }).count()
        if annosFound > 0
          docsFound .push docFound

      docsFound

    codesSelected: () ->
      #Are any codeId's selected?
      Template.instance().selectedCodes.find().count()

    annotationsInDoc: (docContext, codeKeyword) ->
      #annotations on this document with the current selected codeId
      annos = Annotations.find({documentId: docContext._id, codeId: codeKeyword._id }).fetch()
      _.each annos, (anno) ->
        anno.annoText = Spacebars.SafeString docContext.body.substring(anno.startOffset, anno.endOffset)
      _.sortBy annos, (anno) ->
        +anno.startOffset
    
  Template.documents.events
    'click .selectable-code': (event, template) ->
      selectedId  = event.currentTarget.getAttribute('data-id') 
      selectedDoc = Template.instance().selectedCodes.findOne { "codeKeyword._id": selectedId } 
      if _.isUndefined(selectedDoc)
        codeKeyword = CodingKeywords.findOne { _id: selectedId }
        Template.instance().selectedCodes.insert( { codeKeyword }  )
     
    'click .dismiss-selected': (event, template) ->
      selectedId  = event.currentTarget.getAttribute('data-id')
      selectedDoc = Template.instance().selectedCodes.findOne { "codeKeyword._id": selectedId } 
      Template.instance().selectedCodes.remove selectedDoc._id;

if Meteor.isServer
  Meteor.publish 'documents', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      Documents.find()
    else if user
      Documents.find { groupId: user.group }

  Meteor.publish 'annotationsWithCodeId', (codeId) ->
    Annotations.find({codeId: codeId})



