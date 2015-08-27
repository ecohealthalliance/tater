if Meteor.isClient
  Template.annotations.onCreated ->
    @subscribe('documents')
    @subscribe('annotations')
    @subscribe('CodingKeywords')
    @selectedCodes  = new Meteor.Collection(null)
    @annotations = new ReactiveVar()

  Template.annotations.onRendered ->
    instance = Template.instance()
    @autorun ->
      selectedCodes = instance.selectedCodes.find().fetch()

      if selectedCodes.length
        query = _.map selectedCodes, (code) ->
          {codeId: code.codeKeyword._id}
        query = {$or:query}
      else
        query = {}

      annotations = _.map Annotations.find(query).fetch(), (annotation) ->
        doc = Documents.findOne({_id: annotation.documentId})
        annotatedText: Spacebars.SafeString doc.body.substring(annotation.startOffset, annotation.endOffset)
        user: Meteor.users.findOne(annotation.userId).emails[0].address
        documentTitle: doc.title
        documentId: doc._id
        groupId: doc.groupId
        codeId: annotation.codeId

      annotationsByCode = _.map _.groupBy(annotations, 'codeId'), (annotations, codeId) ->
        code: CodingKeywords.findOne({_id: codeId})
        annotations: annotations

      instance.annotations.set(_.sortBy annotationsByCode, (annotation) -> annotation.code.header)

  Template.annotations.helpers
    annotationsByCode: ->
      Template.instance().annotations.get()
    codeString: ->
      if @code.header and @code.subHeader and @code.keyword
        Spacebars.SafeString("<span class='header'>#{@code.header}</span> : <span class='sub-header'>#{@code.subHeader}</span> : <span class='keyword'>#{@code.keyword}</span>")
      else if @code.subHeader and not @code.keyword
        Spacebars.SafeString("<span class='header'>#{@code.header}</span> : <span class='sub-header'>#{@code.subHeader}</span>")
      else if @code.header
        Spacebars.SafeString("<span class='header'>"+@code.header+"</span>")
      else
        ''
    selectedCodes: ->
      Template.instance().selectedCodes

    icon: ->
      if @code.header is 'Human Movement' then 'fa-bus'
      else if @code.header is 'Socioeconomics' then 'fa-money'
      else if @code.header is 'Biosecurity in Human Environments' then 'fa-lock'
      else if @code.header is 'Illness Medical Care/Treatment and Death' then 'fa-medkit'
      else if @code.header is 'Human Animal Contact' then 'fa-paw'

  Template.annotations.events
    'click .selectable-code': (event, template) ->
      selectedId  = event.currentTarget.getAttribute('data-id')
      codeKeyword = CodingKeywords.findOne { _id: selectedId }
      selected = Template.instance().selectedCodes.findOne { "codeKeyword._id": selectedId }
      hasAnnotation = Annotations.findOne({codeId: codeKeyword._id})
      if not selected and hasAnnotation
        Template.instance().selectedCodes.insert({ codeKeyword })
      else
        Template.instance().selectedCodes.remove({ codeKeyword })

    'click .dismiss-selected': (event, template) ->
      selectedId  = event.currentTarget.getAttribute('data-id')
      selectedDoc = Template.instance().selectedCodes.findOne { "codeKeyword._id": selectedId }
      Template.instance().selectedCodes.remove selectedDoc._id;

if Meteor.isServer

  Meteor.publish 'annotations', ->
    user = Meteor.users.findOne({_id: @userId})
    if user?.admin
      documents = Documents.find({}, {_id: 1}).fetch()
    else if user
      documents = Documents.find({ groupId: user.group }, {_id: 1}).fetch()
    docIds = _.pluck documents, '_id'
    Annotations.find({documentId: $in:docIds})
