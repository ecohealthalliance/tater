if Meteor.isClient

  $annotationSpanElement = (annotationId) ->
    $(".document-text span[data-annotation-id='#{annotationId}']")

  highlightText = (annotationId) ->
    $(".document-text span").addClass('not-highlighted')
    $annotationSpanElement(annotationId).addClass('highlighted').removeClass('not-highlighted')

  scrollToAnnotation = (annotationId, scrollList) ->
    $annotationText = $(".document-text span[data-annotation-id='#{annotationId}']")
    $annotationInList = $("ul.annotations li[data-annotation-id='#{annotationId}']")
    unless scrollList
      $('.document-container').animate { scrollTop: ($annotationText.position().top - $annotationInList.position().top + ($annotationText.height() / 2) + 45) }, 1000, 'easeInOutQuint'
    else
      annotationDocTop  = $annotationSpanElement(annotationId).position()?.top + 10
      annotationListTop = $annotationInList.position()?.top - 85
      $('.document-container').animate { scrollTop: annotationDocTop }, 1000, 'easeInOutQuint'
      $('.annotation-container').animate { scrollTop: annotationListTop }, 1000, 'easeInOutQuint'

  Template.documentDetail.onCreated ->
    if @data.generateCode
      @accessCode = Date.now()
    @subscribe('documentDetail', @data.documentId, @accessCode)
    @subscribe('docAnnotations', @data.documentId, @accessCode)
    @subscribe('users', @data.documentId, @accessCode)
    @startOffset = new ReactiveVar()
    @endOffset = new ReactiveVar()
    @annotations = new ReactiveVar()
    @searchText = new ReactiveVar('')
    @temporaryAnnotation = new ReactiveVar(new Annotation())
    @selectedAnnotation = new ReactiveVar({id: @data.annotationId, onLoad: true})

  Template.documentDetail.onRendered ->
    instance = Template.instance()
    @autorun ->
      annotations = Annotations.find({documentId: instance.data.documentId}, sort: {startOffset: 1, _id: 0})
      annotations = _.filter annotations.fetch(), (annotation) ->
        CodingKeywords.findOne(annotation.codeId)

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

    @autorun ->
      selectedAnnotation = instance.selectedAnnotation.get()
      id = selectedAnnotation.id
      if id
        if selectedAnnotation.onLoad
          setTimeout (->
            scrollToAnnotation(id, true)
            highlightText(id)
            ), 400
        else
          highlightText(id)
          scrollToAnnotation(id, false)

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'annotations': ->
      Template.instance().annotations.get()

    'accessCode': ->
      Template.instance().accessCode

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
      id = Template.instance().selectedAnnotation.get()?.id
      if @_id is id
        'selected'
      else if id
        'not-selected'

  Template.documentDetail.events
    'mousedown .document-container': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      temporaryAnnotation.set({startOffset: null, endOffset: null})
      instance.temporaryAnnotation.set(temporaryAnnotation)

    'click .annotations li': (event, template) ->
      annotationId = event.currentTarget.getAttribute('data-annotation-id')
      selectedAnnotation = template.selectedAnnotation
      unless selectedAnnotation.get().id is annotationId
        selectedAnnotation.set({id: annotationId})
      else
        selectedAnnotation.set({id: null})
        $annotationSpanElement(annotationId).removeClass('highlighted')
        $(".document-annotations span").removeClass('not-highlighted')

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
      if temporaryAnnotation.startOffset?
        attributes = {}
        attributes['codeId'] = event.currentTarget.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startOffset'] = temporaryAnnotation.startOffset
        attributes['endOffset'] = temporaryAnnotation.endOffset
        Meteor.call('createAnnotation', attributes, instance.accessCode)

        temporaryAnnotation.set({startOffset: null, endOffset: null})
        instance.temporaryAnnotation.set(temporaryAnnotation)

    'keyup .annotation-search': _.debounce ((e, instance) -> instance.searchText.set e.target.value), 200

    'click .delete-annotation': (event, instance) ->
      event.stopImmediatePropagation()
      target = event.currentTarget
      annotationId = target.getAttribute('data-annotation-id')
      $(target).parent().addClass('deleting')
      setTimeout (->
        Meteor.call 'deleteAnnotation', annotationId, instance.accessCode
        if annotationId is instance.selectedAnnotation.get()
          $(".document-annotations span").removeClass('not-highlighted')
        ), 800

    'click .toggle-flag': (event, instance) ->
      event.stopImmediatePropagation()
      target = event.currentTarget
      annotationId = target.getAttribute('data-annotation-id')
      Meteor.call('toggleAnnotationFlag', annotationId)

if Meteor.isServer
  Meteor.publish 'documentDetail', (id, code) ->
    document = Documents.findOne(id)
    if code && document.codeAccessible()
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

  Meteor.publish 'docAnnotations', (documentId, code) ->
    document = Documents.findOne(documentId)
    if code && document.codeAccessible()
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
    else if @userId
      document = Documents.findOne(documentId)
      group = Groups.findOne({_id: document.groupId})
      Meteor.users.find
        group: group._id
        fields:
          emails: 1
    else
      @ready()

  Meteor.methods
    createAnnotation: (attributes, code) ->
      document = Documents.findOne(attributes.documentId)
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      accessible = (code and document.codeAccessible()) or (user and group?.viewableByUser(user))
      if accessible
        annotation = new Annotation()
        annotation.set(attributes)
        annotation.set(userId: @userId)
        annotation.set(accessCode: code)
        annotation.save ->
          document.set("annotated", Annotations.find({documentId: document._id}).count())
          document.save()
          annotation
      else
        throw 'Unauthorized'

    deleteAnnotation: (annotationId, code) ->
      annotation = Annotations.findOne(annotationId)
      document = Documents.findOne(annotation.documentId)
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      accessibleViaCode = (code and document.codeAccessible() and (code is annotation.accessCode))
      accessibleViaUser = (user and group?.viewableByUser(user))
      if accessibleViaCode or accessibleViaUser
        annotation.remove ->
          document.set("annotated", Annotations.find({documentId: document._id}).count())
          document.save()
          annotation
      else
        throw 'Unauthorized'

    toggleAnnotationFlag: (annotationId) ->
      annotation = Annotations.findOne(annotationId)
      if annotation.flagged
        annotation.set(flagged: false)
      else
        annotation.set(flagged: true)
      annotation.save()
