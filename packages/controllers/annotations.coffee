AnnotationsPages = new Meteor.Pagination Annotations,
  filters:
    documentId: {$in: []}
  sort:
    codeId: 1
  auth: (skip, subscription)->
    # Meteor pagination auth functions break filtering.
    # I am using a work around based on the approach here:
    # https://github.com/alethes/meteor-pages/issues/131
    user = Meteor.users.findOne subscription.userId
    if not user then return false
    userSettings = @userSettings[subscription._session.id] or {}
    userFilters = userSettings.filters or @filters
    userFields = userSettings.fields or @fields
    userSort = userSettings.sort or @sort
    userPerPage = userSettings.perPage or @perPage
    [
      {
        $and: [
          userFilters
          QueryHelpers.limitQueryToUserDocs({}, user)
        ]
      },
      {
        fields: userFields
        sort: userSort
        limit: userPerPage
        skip: skip
      }
    ]
  templateName: 'annotations'
  itemTemplate: 'annotation'
  availableSettings:
    perPage: true
    sort: true
    filters: true

if Meteor.isClient
  Template.annotations.onCreated ->
    @subscribe('groupsAndDocuments')
    @selectedCodes = new Meteor.Collection(null)
    @selectedSubHeaders = new Meteor.Collection(null)
    @selectedHeaders = new Meteor.Collection(null)
    @annotations = new ReactiveVar()
    @showFlagged = new ReactiveVar(false)
    @filtering = new ReactiveVar(false)
    @documents = new Meteor.Collection(null)
    @selectedGroups = new Meteor.Collection(null)
    @keywordQuery = new ReactiveVar({})
    @query = new ReactiveVar({})
    @csvData = new ReactiveVar(null)

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
        query = {$and: [{$or:query}, {userToken: null}] }
      else
        query = {userToken: null}

      if instance.showFlagged.get()
        query.flagged = true

      documents = _.pluck(instance.documents.find().fetch(), 'docID')
      query.documentId = {$in: documents}

      instance.query.set(query)

      annotations =
        _.map Annotations.find(query).fetch(), (annotation) ->
          doc = annotation.document()
          annotatedText: annotation.text()
          user: annotation.userEmail()
          documentTitle: doc.title
          documentId: doc._id
          groupId: doc.groupId
          codeId: annotation.codeId
          annotationId: annotation._id

      annotationsByCode =
        _.map _.groupBy(annotations, 'codeId'), (annotations, codeId) ->
          code: CodingKeywords.findOne codeId
          annotations: annotations

      sortedAnnotations =
        _.chain(annotationsByCode)
          .sortBy((annotation) -> annotation.code?.subheader)
          .sortBy((annotation) -> annotation.code?.header)
          .value()
      instance.annotations.set(sortedAnnotations)

      AnnotationsPages.set
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

    flagged: ->
      Annotations.find(flagged: true).count() or
        Template.instance().showFlagged.get()

    keywordQuery: ->
      Template.instance().keywordQuery

    selectedHeaders: ->
      Template.instance().selectedHeaders

    selectedSubHeaders: ->
      Template.instance().selectedSubHeaders

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
      Template.instance().documents.find().count() or
        Template.instance().selectedGroups.find().count()

    noAnnotations: ->
      if Documents.findOne(@_id).annotated == 0
        'disabled'

    annotationsLoaded: ->
      Template.instance().annotations.get()

    selectedDoc: ->
      if Template.instance().documents.find({docID: @_id}).count()
        'selected'

    selectedGroup: ->
      if Template.instance().selectedGroups.find({id: @_id}).count() and
          Documents.find({groupId: @_id}).count()
        'selected'

    groups: ->
      Groups.find({}, {sort: {name: 1}})

    groupDocuments: ->
      # lets us break arrays with annotations and without annotations apart and
      # sort them separately. This allows us to keep unannotated documents at
      # the bottom of the list and then sort them by title.
      annotatedDocs = Documents.find(
        { groupId: @_id, annotated: {$gt: 0} }, { sort: {title: 1} }
      ).fetch()
      unAnnotatedDocs = Documents.find(
        {
          $and:[
            groupId: @_id,
            $or: [
              { annotated: {$lt: 1} },
              { annotated: {$exists: false} }
            ]
          ]
        },
        { sort: {title: 1} }
      ).fetch()
      annotatedDocs.concat(unAnnotatedDocs)

    allSelected: ->
      Template.instance().documents.find().count() == Documents.find().count()

    toggleEnabled: ->
      if Documents.find(groupId: @_id).count()
        'enabled'
      else
        'disabled'

    csvDataUri: ->
      csvData = Template.instance().csvData.get()
      if csvData
        'data:text/csv;charset=utf-8,' + encodeURIComponent(csvData)

    showGroup: ->
      Template.instance().selectedGroups.findOne({id: @_id})

  # Commmon functions for template events
  resetKeywords = () ->
    instance = Template.instance()
    instance.filtering.set(false)
    instance.selectedCodes.remove({})

  resetPage = () ->
    AnnotationsPages.sess('currentPage', 1)

  Template.annotations.events
    'click .download-csv': (event, instance) ->
      instance.csvData.set(null)
      $('#download-csv-modal').modal('show')
      Meteor.call 'generateCsv', instance.query.get(), ((err, csvData)->
        if err
          $('#download-csv-modal').modal('hide')
          toastr.error 'CSV Generation Error: ' + err
        else
          instance.csvData.set(csvData)
      )

    'click .show-flagged': (event, instance) ->
      unless event.currentTarget.childNodes[0].disabled
        resetPage()
        instance.showFlagged.set(!instance.showFlagged.get())

    'click .document-selector': (event, instance) ->
      resetKeywords()
      selectedDocID = $(event.currentTarget).data('id')
      documents = instance.documents
      docQuery = docID: selectedDocID
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
        docQuery = docID: doc._id
        if showGroup
          selectedDocs.insert(docQuery)
        else
          selectedDocs.remove(docQuery)

    'click .group-selector.enabled i': (event, instance) ->
      $(event.target).toggleClass('down up').parent().siblings('.group-docs').toggleClass('hidden')

    'click .select-all': (event, instance) ->
      _.each Documents.find().fetch(), (doc) ->
        docQuery = docID: doc._id
        unless instance.documents.find(docQuery).count()
          instance.documents.insert(docQuery)
      _.each Groups.find().fetch(), (group) ->
        unless instance.selectedGroups.find(id: group._id).count()
          instance.selectedGroups.insert(id: group._id)

    'click .selectable-header': (event, instance) ->
      resetPage()
      selectedHeaderId  = event.currentTarget.getAttribute('data-id')
      selectedHeader = Headers.findOne selectedHeaderId
      currentlySelected = instance.selectedHeaders.findOne selectedHeaderId

      instance.filtering.set(true)
      subHeaders = SubHeaders.find(headerId: selectedHeaderId).fetch()
      codeKeywords = CodingKeywords.find({subHeaderId: {$in: _.pluck(subHeaders, '_id')}}).fetch()

      if currentlySelected
        instance.selectedHeaders.remove(selectedHeader)
        _.each subHeaders, (subHeader) ->
          instance.selectedSubHeaders.remove(subHeader)
        _.each codeKeywords, (codeKeyword) ->
          instance.selectedCodes.remove(codeKeyword)
      else
        instance.selectedHeaders.upsert({_id: selectedHeader._id}, selectedHeader)
        _.each subHeaders, (subHeader) ->
          instance.selectedSubHeaders.upsert({_id: subHeader._id}, subHeader)
        _.each codeKeywords, (codeKeyword) ->
          instance.selectedCodes.upsert({_id: codeKeyword._id}, codeKeyword)

    'click .selectable-subheader': (event, instance) ->
      resetPage()
      selectedSubHeaderId  = event.currentTarget.getAttribute('data-id')
      selectedSubHeader = SubHeaders.findOne selectedSubHeaderId
      currentlySelected = instance.selectedSubHeaders.findOne selectedSubHeaderId

      instance.filtering.set(true)
      codeKeywords = CodingKeywords.find(subHeaderId: selectedSubHeaderId).fetch()

      if currentlySelected
        instance.selectedSubHeaders.remove(selectedSubHeader)
        _.each codeKeywords, (codeKeyword) ->
          instance.selectedCodes.remove(codeKeyword)
      else
        instance.selectedSubHeaders.upsert({_id: selectedSubHeader._id}, selectedSubHeader)
        _.each codeKeywords, (codeKeyword) ->
          instance.selectedCodes.upsert({_id: codeKeyword._id}, codeKeyword)

    'click .selectable-keyword': (event, instance) ->
      resetPage()
      selectedCodeKeywordId  = event.currentTarget.getAttribute('data-id')
      selectedCodeKeyword = CodingKeywords.findOne selectedCodeKeywordId
      currentlySelected = instance.selectedCodes.findOne selectedCodeKeywordId
      keyword = selectedCodeKeyword?.keyword

      instance.filtering.set(true)

      if currentlySelected
        instance.selectedCodes.remove(selectedCodeKeyword)
      else
        instance.selectedCodes.upsert({_id: selectedCodeKeyword._id}, selectedCodeKeyword)

    'click .clear-filters': (event, instance) ->
      instance.documents.remove({})
      instance.selectedGroups.remove({})

    'click .download-csv-btn': (event) ->
      $('#download-csv-modal').modal('hide')

    'click .pagination li': (event, instance)->
      instance.$('.annotations-list-container').scrollTop(0)

  Template.annotation.onCreated ->
    @annotation = new Annotation(_.pick(@data, _.keys(Annotation.getFields())))
    @document = @annotation.document()
    @code = @annotation._codingKeyword()

  Template.annotation.onRendered ->
    # This hides the code keyword labels for all but the first element of a
    # a code group.
    prevAnnotationCodeText = @$(@.firstNode).prev().find('h3').text()
    annotationCodeText = @$('h3').text()
    if prevAnnotationCodeText == annotationCodeText
      @$('h3').addClass('hidden')

  Template.annotation.helpers
    annotatedText: ->
      Template.instance().annotation.text()
    documentTitle: ->
      Template.instance().document.title
    documentId: ->
      Template.instance().document._id
    routeData: ->
      params:
        _id: Template.instance().document._id
      query:
        annotationId: Template.instance().annotation._id
    user: ->
      Template.instance().annotation.userEmail()
    codeColor: ->
      Template.instance().annotation.color()
    codeString: ->
      code = Template.instance().code
      header = code?.headerLabel()
      subHeader = code?.subHeaderLabel()
      keyword = code?.label
      Spacebars.SafeString("""
        <span class="header">#{header}</span> :
        <span class="sub-header">#{subHeader}</span> :
        <span class="keyword">#{keyword}</span>
      """)


Meteor.methods
  generateCsv: (query) ->
    user = Meteor.users.findOne @userId
    if user?
      if user?.admin
        documents = Documents.find()
      else if user?
        documents = Documents.find groupId: user.group
      docIds = documents.map((d)-> d._id)
      if query.documentId
        if _.isString query.documentId
          userDocIds = [query.documentId]
        else if query.documentId.$in
          userDocIds = query.documentId.$in
        else
          throw Meteor.Error('Query is not supported')
        if _.difference(userDocIds, docIds).length > 0
          throw Meteor.Error('Invalid docIds')
      else
        query.documentId = $in: docIds
      headerGetters =
        documentId: (annotation)-> annotation.documentId
        userEmail: (annotation)-> annotation.userEmail()
        header: (annotation)-> annotation.header()
        subHeader: (annotation)-> annotation.subHeader()
        keyword: (annotation)-> annotation.keyword()
        text: (annotation)-> annotation.text().string
        flagged: (annotation)-> Boolean(annotation.flagged)
        createdAt: (annotation)-> annotation.createdAt
      # This BOM is needed to make modern versions of Excel open the CSV
      # using the correct encoding.
      # See: http://stackoverflow.com/questions/155097/microsoft-excel-mangles-diacritics-in-csv-files
      excelBOM = '\uFEFF'
      excelBOM + Baby.unparse
        fields: _.keys(headerGetters)
        data: Annotations.find(query).map((annotation)->
          _.map(headerGetters, (getValue, header)->
            getValue(annotation)
          )
        )


if Meteor.isServer
  Meteor.publish 'groupsAndDocuments', ->
    user = Meteor.users.findOne @userId
    groups = Groups.find()
    if user?
      if user?.admin
        documents = Documents.find()
      else
        documents = Documents.find groupId: user.group
      [ groups, documents ]
    else
      @ready()
