if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId, @data.code)
    @subscribe('annotations', @data.documentId, @data.code)
    @subscribe('users', @data.documentId, @data.code)
    @startOffset = new ReactiveVar()
    @endOffset = new ReactiveVar()
    @selectedAnnotation = new ReactiveVar(null)
    @annotations = new ReactiveVar()
    @searchText = new ReactiveVar('')
    @temporaryAnnotation = new ReactiveVar(new Annotation())

  Template.documentDetail.onRendered ->
    instance = Template.instance()
    @autorun ->
      annotations = Annotations.find({documentId: instance.data.documentId}, sort: startOffset: 1)
      if instance.searchText.get() is ''
        instance.annotations.set annotations
      else
        searchText = instance.searchText.get().split(' ')
        filteredAnnotations = _.filter annotations.fetch(), (annotation) ->
          code = CodingKeywords.findOne(annotation.codeId)
          wordMatches = _.filter searchText, (word) ->
            word = new RegExp(word, 'i')
            code.header?.match(word) or code.subHeader?.match(word) or code.keyword?.match(word)
          wordMatches.length
        instance.annotations.set _.sortBy filteredAnnotations, 'startOffset'

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'annotations': ->
      Template.instance().annotations.get()

    'annotationUserEmail': ->
      @userEmail()

    'annotationLayers': ->
      temporaryAnnotation = Template.instance().temporaryAnnotation.get()
      annotations = Annotations.find({documentId: @documentId}).fetch()
      if temporaryAnnotation.startOffset >= 0
        annotations.push(temporaryAnnotation)
      document = Documents.findOne({ _id: @documentId })

      annotationLayers = _.map annotations, (annotation) =>
        annotatedBody = document.textWithAnnotation(annotation)
        Spacebars.SafeString(annotatedBody)
      annotationLayers

    'positionInformation': ->
      "#{@startOffset} - #{@endOffset}"

    'header': ->
      @header()

    'subHeader': ->
      @subHeader()

    'keyword': ->
      @keyword()

    'color': ->
      @color()

    'code': ->
      if @header() and @subHeader() and @keyword()
        Spacebars.SafeString("<span class='header'>#{@header()}</span> : <span class='sub-header'>#{@subHeader()}</span> : <span class='keyword'>#{@keyword()}</span>")
      else if @subHeader() and not @keyword()
        Spacebars.SafeString("<span class='header'>#{@header()}</span> : <span class='sub-header'>#{@subHeader()}</span>")
      else if @header()
        Spacebars.SafeString("<span class='header'>"+@header()+"</span>")
      else
        ''

    'selected': ->
      if @_id is Template.instance().selectedAnnotation.get()
        'selected'

  Template.documentDetail.events
    'mousedown .document-container': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      temporaryAnnotation.set({startOffset: null, endOffset: null})
      instance.temporaryAnnotation.set(temporaryAnnotation)

    'click .annotations li': (event, template) ->
      annotationId = event.currentTarget.getAttribute('data-annotation-id')
      documentAnnotation = $(".document-annotations span[data-annotation-id='#{annotationId}']")

      if template.selectedAnnotation.get() is @_id
        template.selectedAnnotation.set(null)
        documentAnnotation.removeClass('highlighted')
        $(".document-annotations span").removeClass('not-highlighted')
      else
        template.selectedAnnotation.set(@_id)
        $(".document-annotations span").addClass('not-highlighted')
        documentAnnotation.addClass('highlighted').removeClass('not-highlighted')
        $('.document-container').animate { scrollTop: ($(".document-annotations span[data-annotation-id='#{annotationId}']").position().top - $("li[data-annotation-id='#{annotationId}']").position().top + ($(".document-annotations span[data-annotation-id='#{annotationId}']").height() / 2) + 45) }, 1000, 'easeInOutQuint'

    'click .document-detail-container': (event, instance) =>
      instance.startOffset.set(null)
      instance.endOffset.set(null)

    'click .document-container': (event, instance) =>
      temporaryAnnotation = instance.temporaryAnnotation.get()

      selection = window.getSelection()
      range = selection.getRangeAt(0)
      selectionInDocument = selection.anchorNode.parentElement.getAttribute('class') == 'document-text'
      textHighlighted = range and (range.endOffset > range.startOffset)

      if selectionInDocument and textHighlighted
        startOffset = range.startOffset
        endOffset = range.endOffset

        temporaryAnnotation.set({startOffset: startOffset, endOffset: endOffset})
        instance.temporaryAnnotation.set(temporaryAnnotation)
        selection.empty()

    'click .selectable-code': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      if temporaryAnnotation.startOffset >= 0
        attributes = {}
        attributes['codeId'] = event.currentTarget.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startOffset'] = temporaryAnnotation.startOffset
        attributes['endOffset'] = temporaryAnnotation.endOffset
        Meteor.call('createAnnotation', attributes, instance.data.code)

        temporaryAnnotation.set({startOffset: null, endOffset: null})
        instance.temporaryAnnotation.set(temporaryAnnotation)

    'keyup .annotation-search': _.debounce ((e, instance) -> instance.searchText.set e.target.value), 200

    'click .delete-annotation': (event, instance) ->
      event.stopPropagation()
      target = event.currentTarget
      annotationId = target.getAttribute('data-annotation-id')
      $(target).parent().addClass('deleting')
      setTimeout (->
        Meteor.call 'deleteAnnotation', annotationId, instance.data.code
        if annotationId is instance.selectedAnnotation.get()
          $(".document-annotations span").removeClass('not-highlighted')
        ), 800

if Meteor.isServer
  Meteor.publish 'documentDetail', (id, code) ->
    document = Documents.findOne(id)
    if code
      Documents.find id
    else if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUser(user)
        Documents.find id
      else
        @ready()
    else
      @ready()

  Meteor.publish 'annotations', (documentId, code) ->
    document = Documents.findOne(documentId)
    if code
      Annotations.find({documentId: documentId, accessCode: code})
    else if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUser(user)
        Annotations.find({documentId: documentId})
      else
        @ready()
    else
      @ready()

  Meteor.publish 'users', (documentId, code) ->
    if code
      @ready()
    else
      document = Documents.findOne(documentId)
      group = Groups.findOne({_id: document.groupId})
      Meteor.users.find
        group: group._id
        fields:
          emails: 1

  Meteor.methods
    createAnnotation: (attributes, code) ->
      document = Documents.findOne(attributes.documentId)
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      accessible = code or (user and group?.viewableByUser(user))
      if accessible
        annotation = new Annotation()
        annotation.set(attributes)
        annotation.set(userId: @userId)
        annotation.set(accessCode: code)
        annotation.save ->
          annotation
      else
        throw 'Unauthorized'

    deleteAnnotation: (annotationId, code) ->
      annotation = Annotations.findOne(annotationId)
      document = Documents.findOne(annotation.documentId)
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      accessible = code or (user and group?.viewableByUser(user))
      if accessible
        annotation.remove() ->
          annotation
      else
        throw 'Unauthorized'
