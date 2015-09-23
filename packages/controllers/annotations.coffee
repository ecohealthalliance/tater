if Meteor.isClient
  Template.annotations.onCreated ->
    @subscribe('annotationsAndDocuments')
    @subscribe('CodingKeywords')
    @selectedCodes  = new Meteor.Collection(null)
    @annotations = new ReactiveVar()
    @showFlagged = new ReactiveVar(false)

  Template.annotations.onRendered ->
    instance = Template.instance()
    @autorun ->
      selectedCodes = instance.selectedCodes.find().fetch()
      if selectedCodes.length
        query = _.map selectedCodes, (code) ->
          {codeId: code._id}
        query = {$and: [{$or:query}, {accessCode: null}] }
      else
        query = {accessCode: null}

      if instance.showFlagged.get()
        query.flagged = true

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

  Template.annotations.helpers
    annotationsByCode: ->
      Template.instance().annotations.get()
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

  Template.annotations.events
    'click .show-flagged': (event) ->
      Template.instance().showFlagged.set(!Template.instance().showFlagged.get())

    'click .annotation-detail': (event, template) ->
      annotationId  = event.currentTarget.getAttribute('data-annotation-id')
      documentId    = event.currentTarget.getAttribute('data-doc-id')
      go "documentDetailWithAnnotation", {"_id": documentId, "annotationId" : annotationId}

    'click .selectable-code': (event, template) ->
      selectedCodeKeywordId  = event.currentTarget.getAttribute('data-id')
      selectedCodeKeyword = CodingKeywords.findOne(selectedCodeKeywordId)
      currentlySelected = Template.instance().selectedCodes.findOne(selectedCodeKeywordId)
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
            Template.instance().selectedCodes.upsert({_id: codeKeyword._id}, codeKeyword)
        else
          Template.instance().selectedCodes.upsert({_id: codeKeyword._id}, codeKeyword)
      else
        if codeKeywords
          _.each codeKeywords, (codeKeyword) ->
            Template.instance().selectedCodes.remove(codeKeyword)
        else
          Template.instance().selectedCodes.remove(codeKeyword)

if Meteor.isServer

  Meteor.publish 'annotationsAndDocuments', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      documents = Documents.find({})
    else if user
      documents = Documents.find({ groupId: user.group })
    docIds = documents.map((d)-> d._id)
    [
      documents
      Annotations.find
        documentId: {$in: docIds}
    ]
