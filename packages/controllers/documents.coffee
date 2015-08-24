if Meteor.isClient
  Template.documents.onCreated ->
    @subscribe('documents')
    @subscribe('groups')
    @subscribe('codingKeywords')    
    @selectedCodes  = new Meteor.Collection(null);
    @searchResults   = new ReactiveVar([])
    @annoResults   = new ReactiveVar([])
    
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

    searchResults: () ->
      #All codes on left selected
      Template.instance().searchResults = []

      #Clicked/Searched code IDs
      selectedCodes = Template.instance().selectedCodes.find().fetch()
     
      #All annotations we have access too, subscribed too dynamically based on all selected codeIds
      colAnnotations = Annotations.find().fetch(); 

      #All documents with annotations we are (dynamically) subscribed too
      uniqueDocsWithAnnotations = _.unique _.pluck(colAnnotations, 'documentId')

      #build collection of annotations by codeID and document      
      _.each selectedCodes, (code) ->

        #Edge case - this codeID has no annotations on any documents, still want it to show up in search area after selecting
        if uniqueDocsWithAnnotations.length == 0 
          entry = {};
          entry.docs = [];
          entry.annotations = [];
          entry.codeId = code.codeKeyword._id
          entry.code = code
          Template.instance().searchResults.push entry  

        _.each uniqueDocsWithAnnotations, (uniqueDocId) ->
          docFound  = Documents.findOne { _id: uniqueDocId }

          #annotations on this document with the current selected codeId
          annosFound = Annotations.find({documentId: uniqueDocId, codeId: code.codeKeyword._id }).fetch();

          #Each entry in search result represents a codeId centric result. One result per selected CodeId.
          #So put all results for this given codeId into this entry.
          #There is probably a more 'meteor' way of doing this. TBD Ask Amy
          entry = _.find Template.instance().searchResults, (entryCheck) ->
            entryCheck.codeId == code.codeKeyword._id

          if _.isUndefined(entry) and annosFound.length > 0
            entry = {};
            entry.docs = [];
            entry.annotations = [];
            entry.codeId = code.codeKeyword._id
            entry.code = code
            entry.docs.push docFound
            _.each annosFound, (anno) ->
              anno.annoText = Spacebars.SafeString docFound.body.substring(anno.startOffset, anno.endOffset)
            entry.annotations = entry.annotations.concat annosFound
            Template.instance().searchResults.push entry  
          else if _.isUndefined(entry) and annosFound.length == 0      
            entry = {};
            entry.docs = [];
            entry.annotations = [];
            entry.codeId = code.codeKeyword._id
            entry.code = code
            Template.instance().searchResults.push entry  
          else if annosFound.length > 0
            entry.docs.push docFound
            entry.annotations = entry.annotations.concat annosFound
            _.each annosFound, (anno) ->
              anno.annoText = Spacebars.SafeString docFound.body.substring(anno.startOffset, anno.endOffset)

      #return populated searchResults
      Template.instance().searchResults

    codesSelected: () ->
      #Are any codeId's selected?
      Template.instance().selectedCodes.find().count()

    annosInDoc: (docContext, codeId) ->
      #Given a document context, and codeId, find relavent annotations
      entry = _.find Template.instance().searchResults, (entryCheck) ->
        entryCheck.codeId == codeId

      Template.instance().annoResults = _.filter entry.annotations, (annotation) ->
        annotation.documentId == docContext._id

      Template.instance().annoResults

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



