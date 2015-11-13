limitQueryToUserDocs = (query, user)->
  if user?.admin
    codeInaccessibleGroups = Groups.find({codeAccessible: {$ne: true}})
    codeInaccessibleGroupIds = _.pluck(codeInaccessibleGroups.fetch(), '_id')
    documents = Documents.find({groupId: {$in: codeInaccessibleGroupIds}})
  else
    documents = Documents.find({ groupId: user.group })

  docIds = documents.map((d)-> d._id)
  if query.documentId
    if _.isString query.documentId
      userDocIds = [query.documentId]
    else if query.documentId.$in
      userDocIds = query.documentId.$in
    else
      throw Meteor.Error("Query is not supported")
    if _.difference(userDocIds, docIds).length > 0
      throw Meteor.Error("Invalid docIds")
  else
    query.documentId = {$in: docIds}
  query

Pages = new Meteor.Pagination Annotations,
  filters:
    documentId: {$in: []}
  sort:
    codeId: 1
  auth: (skip, subscription)->
    [limitQueryToUserDocs({}, Meteor.users.findOne({_id: subscription.userId}))]
  itemTemplate: "annotation"
  availableSettings:
    perPage: true
    sort: true
    filters: true

if Meteor.isClient
  Template.annotations.onCreated ->
    @subscribe('groupsAndDocuments')
    @subscribe('codingKeywords')
    @selectedCodes  = new Meteor.Collection(null)
    @annotations = new ReactiveVar()
    @showFlagged = new ReactiveVar(false)
    @filtering = new ReactiveVar(false)
    @documents = new Meteor.Collection(null)
    @selectedGroups = new Meteor.Collection(null)
    @keywordQuery = new ReactiveVar({})

  Template.annotations.onRendered ->
    instance = Template.instance()
    @autorun ->
      docIds = _.pluck(instance.documents.find().fetch(), 'docID')
      query =
        documentId: {$in: docIds}
      if instance.showFlagged.get()
        query.flagged = true
      instance.keywordQuery.set(query)

    @autorun ->
      selectedCodes = instance.selectedCodes.find().fetch()
      query = {}
      if selectedCodes.length
        query = _.map selectedCodes, (code) ->
          {codeId: code._id}
        query = {$and: [{$or:query}, {accessCode: null}] }
      else
        query = {accessCode: null}

      if instance.showFlagged.get()
        query.flagged = true

      documents = _.pluck(instance.documents.find().fetch(), 'docID')
      query.documentId = {$in: documents}

      Pages.set
        filters: query

  Template.annotations.helpers
    documents: ->
      Documents.find().fetch().sort((a,b)->
        if a.groupName() > b.groupName()
          1
        else if a.groupName() < b.groupName()
          -1
        else
          if a.title > b.title
            1
          else if a.title == b.title
            0
          else
            -1
      )
    keywordQuery: ->
      Template.instance().keywordQuery

    selectedCodes: ->
      Template.instance().selectedCodes

    showFlagged: ->
      Template.instance().showFlagged.get()

    docGroup: ->
      @groupName()

    selectionState: (attr) ->
      if Template.instance().documents.find().count() is 0
        if attr is 'class'
          'muted'
        else
          true

    documentSelected: ->
      Template.instance().documents.find().count() or Template.instance().selectedGroups.find().count()

    selectedDoc: ->
      if Template.instance().documents.find({docID:@_id}).count()
        'selected'

    selectedGroup: ->
      if Template.instance().selectedGroups.find({id:@_id}).count() and Documents.find({groupId:@_id}).count()
        'selected'

    groups: ->
      Groups.find({}, {sort: {name: 1}})

    groupDocuments: ->
      Documents.find({groupId: @_id}, {sort: {title: 1}})

    allSelected: ->
      if Template.instance().documents.find().count() == Documents.find().count()
        true

    toggleEnabled: ->
      if Documents.find({groupId: @_id}).count()
        'enabled'
      else
        'disabled'

  resetKeywords = ->
    instance = Template.instance()
    instance.filtering.set(false)
    instance.selectedCodes.remove({})

  resetPage = ->
    Pages.sess("currentPage", 1)

  Template.annotations.events
    'click .show-flagged': (event, instance) ->
      resetPage()
      instance.showFlagged.set(!instance.showFlagged.get())

    'click .annotation-detail': (event, instance) ->
      annotationId  = event.currentTarget.getAttribute('data-annotation-id')
      documentId    = event.currentTarget.getAttribute('data-doc-id')
      go "documentDetailWithAnnotation", {"_id": documentId, "annotationId" : annotationId}

    'click .document-selector': (event, instance) ->
      resetKeywords()
      selectedDocID = $(event.currentTarget).data('id')
      documents = instance.documents
      docQuery = {docID:selectedDocID}
      if documents.find(docQuery).count()
        documents.remove(docQuery)
      else
        documents.insert(docQuery)

    'click .group-selector.enabled span': (event, instance) ->
      resetKeywords()
      resetPage()
      groupId = $(event.currentTarget).parent().data('group')
      selectedDocs = instance.documents
      selectedGroups = instance.selectedGroups
      groupDocs = Documents.find({groupId: groupId})
      if selectedGroups.find({id: groupId}).count()
        selectedGroups.remove({id: groupId})
      else
        selectedGroups.insert({id: groupId})
        showGroup = true

      _.each groupDocs.fetch(), (doc) ->
        docQuery = {docID:doc._id}
        if showGroup
          selectedDocs.insert(docQuery)
        else
          selectedDocs.remove(docQuery)

    'click .group-selector.enabled i': (event, instance) ->
      $(event.target).toggleClass('down up').parent().siblings('.group-docs').toggleClass('hidden')

    'click .select-all': (event, instance) ->
      _.each Documents.find().fetch(), (doc) ->
        docQuery = {docID:doc._id}
        unless instance.documents.find(docQuery).count()
          instance.documents.insert(docQuery)
      _.each Groups.find().fetch(), (group) ->
        unless instance.selectedGroups.find({id:group._id}).count()
          instance.selectedGroups.insert({id:group._id})

    'click .selectable-code': (event, instance) ->
      resetPage()
      selectedCodeKeywordId  = event.currentTarget.getAttribute('data-id')
      selectedCodeKeyword = CodingKeywords.findOne(selectedCodeKeywordId)
      currentlySelected = instance.selectedCodes.findOne(selectedCodeKeywordId)
      header = selectedCodeKeyword?.header
      subHeader = selectedCodeKeyword?.subHeader
      keyword = selectedCodeKeyword?.keyword

      instance.filtering.set(true)

      if not subHeader and not keyword
        codeKeywords = CodingKeywords.find({ header: header }).fetch()
      else if not keyword
        codeKeywords = CodingKeywords.find({ $and: [{header: header},{subHeader: subHeader}] }).fetch()
      else
        codeKeyword = CodingKeywords.findOne(selectedCodeKeywordId)

      if not currentlySelected
        if codeKeywords
          _.each codeKeywords, (codeKeyword) ->
            instance.selectedCodes.upsert({_id: codeKeyword._id}, codeKeyword)
        else
          instance.selectedCodes.upsert({_id: codeKeyword._id}, codeKeyword)
      else
        if codeKeywords
          _.each codeKeywords, (codeKeyword) ->
            instance.selectedCodes.remove(codeKeyword)
        else
          instance.selectedCodes.remove(codeKeyword)

    'click .clear-filters': (event, instance) ->
      instance.documents.remove({})
      instance.selectedGroups.remove({})

  Template.annotation.onCreated ->
    @annotation = new Annotation(_.pick(@data, _.keys(Annotation.getFields())))
    @document = @annotation.document()
    @code = @annotation._codingKeyword()

  Template.annotation.onRendered ->
    # This hides the code keyword labels for all but the first element of a
    # a code group.
    prevAnnotationCodeText = @$(@.firstNode).prev().find("h3").text()
    annotationCodeText = @$("h3").text()
    if prevAnnotationCodeText == annotationCodeText
      @$("h3").hide()

  Template.annotation.helpers
    annotatedText: ->
      Template.instance().annotation.text()
    documentTitle: ->
      Template.instance().document.title
    documentId: ->
      Template.instance().document._id
    user: ->
      Template.instance().annotation.userEmail()
    codeColor: ->
      Template.instance().annotation.color()
    codeString: ->
      header = Template.instance().code?.header
      subHeader = Template.instance().code?.subHeader
      keyword = Template.instance().code?.keyword
      if header and subHeader and keyword
        Spacebars.SafeString("<span class='header'>#{header}</span> : <span class='sub-header'>#{subHeader}</span> : <span class='keyword'>#{keyword}</span>")
      else if subHeader and not keyword
        Spacebars.SafeString("<span class='header'>#{header}</span> : <span class='sub-header'>#{subHeader}</span>")
      else if header
        Spacebars.SafeString("<span class='header'>"+header+"</span>")
      else
        ''
    icon: ->
      header = Template.instance().code?.header
      if header is 'Human Movement' then 'fa-bus'
      else if header is 'Socioeconomics' then 'fa-money'
      else if header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if header is 'Human Animal Contact' then 'fa-paw'

if Meteor.isServer

  Meteor.publish 'groupsAndDocuments', ->
    user = Meteor.users.findOne({_id: @userId})
    codeInaccessibleGroups = Groups.find({codeAccessible: {$ne: true}})
    if user
      if user?.admin
        codeInaccessibleGroupIds = _.pluck(codeInaccessibleGroups.fetch(), '_id')
        documents = Documents.find({groupId: {$in: codeInaccessibleGroupIds}})
      else if user
        documents = Documents.find({ groupId: user.group })
      docIds = documents.map((d)-> d._id)
      [
        documents
        codeInaccessibleGroups
      ]
    else
      @ready()
