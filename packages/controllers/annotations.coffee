if Meteor.isClient
  Template.annotations.onCreated ->
    @subscribe('annotationsGroupsAndDocuments')
    @subscribe('CodingKeywords')
    @selectedCodes  = new Meteor.Collection(null)
    @annotations = new ReactiveVar()
    @selectableCodeIds = new ReactiveVar()
    @showFlagged = new ReactiveVar(false)
    @documents = new Meteor.Collection(null)
    @selectedGroups = new Meteor.Collection(null)

  Template.annotations.onRendered ->
    instance = Template.instance()
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
          code: CodingKeywords.findOne({_id: codeId})
          annotations: annotations

      sortedAnnotations =
        _.chain(annotationsByCode)
          .sortBy((annotation) -> annotation.code?.subheader)
          .sortBy((annotation) -> annotation.code?.header)
          .value()

      instance.annotations.set(sortedAnnotations)
      annotatedCodeIds = _.pluck(_.pluck(sortedAnnotations, 'code'), '_id')
      instance.selectableCodeIds.set(annotatedCodeIds)

  Template.annotations.helpers
    annotationsByCode: ->
      Template.instance().annotations.get()
    selectableCodeIds: ->
      Template.instance().selectableCodeIds
    codeString: ->
      header = @code?.header
      subHeader = @code?.subHeader
      keyword = @code?.keyword
      if header and subHeader and keyword
        Spacebars.SafeString("<span class='header'>#{header}</span> : <span class='sub-header'>#{subHeader}</span> : <span class='keyword'>#{keyword}</span>")
      else if subHeader and not keyword
        Spacebars.SafeString("<span class='header'>#{header}</span> : <span class='sub-header'>#{subHeader}</span>")
      else if header
        Spacebars.SafeString("<span class='header'>"+header+"</span>")
      else
        ''
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

    selectedCodes: ->
      Template.instance().selectedCodes

    showFlagged: ->
      Template.instance().showFlagged.get()

    icon: ->
      header = @code?.header
      if header is 'Human Movement' then 'fa-bus'
      else if header is 'Socioeconomics' then 'fa-money'
      else if header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if header is 'Human Animal Contact' then 'fa-paw'

    docGroup: ->
      @groupName()

    selectionState: (attr) ->
      if Template.instance().documents.find().count() is 0
        if attr is 'class'
          'muted'
        else
          true

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

  Template.annotations.events
    'click .show-flagged': (event, instance) ->
      instance.showFlagged.set(!instance.showFlagged.get())

    'click .annotation-detail': (event, instance) ->
      annotationId  = event.currentTarget.getAttribute('data-annotation-id')
      documentId    = event.currentTarget.getAttribute('data-doc-id')
      go "documentDetailWithAnnotation", {"_id": documentId, "annotationId" : annotationId}

    'click .document-selector': (event, instance) ->
      selectedDocID = $(event.currentTarget).data('id')
      documents = instance.documents
      docQuery = {docID:selectedDocID}
      if documents.find(docQuery).count()
        documents.remove(docQuery)
      else
        documents.insert(docQuery)

    'click .selectable-code': (event, instance) ->
      selectedCodeKeywordId  = event.currentTarget.getAttribute('data-id')
      selectedCodeKeyword = CodingKeywords.findOne(selectedCodeKeywordId)
      currentlySelected = instance.selectedCodes.findOne(selectedCodeKeywordId)
      header = selectedCodeKeyword.header
      subHeader = selectedCodeKeyword.subHeader
      keyword = selectedCodeKeyword.keyword

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

    'click .group-selector.enabled span': (event, instance) ->
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

if Meteor.isServer

  Meteor.publish 'annotationsGroupsAndDocuments', ->
    user = Meteor.users.findOne({_id: @userId})
    codeInaccessibleGroups = Groups.find({codeAccessible: {$ne: true}})
    if user?.admin
      codeInaccessibleGroupIds = _.pluck(codeInaccessibleGroups.fetch(), '_id')
      documents = Documents.find({groupId: {$in: codeInaccessibleGroupIds}})
    else if user
      documents = Documents.find({ groupId: user.group })
    docIds = documents.map((d)-> d._id)
    [
      documents
      codeInaccessibleGroups
      Annotations.find
        documentId: {$in: docIds}
    ]
