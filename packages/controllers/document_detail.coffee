if Meteor.isClient

  $annotationSpanElement = (annotationId) ->
    $ ".document-text span[data-annotation-id='#{annotationId}']"

  highlightText = (annotationId) ->
    if annotationId?
      $(".document-text span").addClass('not-highlighted')
      $annotationSpanElement(annotationId)
        .removeClass('not-highlighted')
        .addClass('highlighted')
    else # unhighlight
      $(".document-text span").removeClass('highlighted, not-highlighted')

  scrollToAnnotation = (annotationId, scrollTheText, scrollTheList, sameLine) ->
    $documentContainer = $ '.document-container'
    documentContainerHeight = $documentContainer.innerHeight()
    documentContainerTopPadding = parseInt $documentContainer.css('padding-top')
    documentBodyTopMargin = parseInt $documentContainer.find('.document-body').css('margin-top')
    documentContainerPaneHeadHeight = parseInt $('.document-heading').innerHeight()
    $documentTextToScrollTo = $documentContainer.find ".document-text span[data-annotation-id='#{annotationId}']"
    documentTextToScrollToHeight = $documentTextToScrollTo.innerHeight()
    documentTextToScrollToTop = $documentTextToScrollTo.position()?.top
    documentTextToScrollToTop += documentContainerTopPadding
    documentTextToScrollToTop -= documentContainerPaneHeadHeight
    documentTextToScrollToTop += documentBodyTopMargin

    $annotationContainer = $ '.annotation-container'
    annotationContainerHeight = $annotationContainer.innerHeight()
    annotationContainerTopPadding = parseInt $annotationContainer.css('padding-top')
    annotationContainerPaneHeadHeight = parseInt $('.annotation-search-container').innerHeight()
    $annotationToScrollTo = $annotationContainer.find "ul.annotations li[data-annotation-id='#{annotationId}']"
    annotationToScrollToHeight = $annotationToScrollTo.innerHeight()
    annotationToScrollToTop = $annotationToScrollTo.position()?.top
    annotationToScrollToTop += annotationContainerTopPadding
    annotationToScrollToTop -= annotationContainerPaneHeadHeight

    if scrollTheText and scrollTheList
      annotationToScrollToTop -= (annotationContainerHeight - annotationContainerPaneHeadHeight - annotationToScrollToHeight) / 2
      $annotationContainer.stop().animate { scrollTop: annotationToScrollToTop }, 1000, 'easeInOutQuint'
      if sameLine
        documentTextToScrollToTop -= (annotationContainerHeight - annotationContainerPaneHeadHeight - annotationToScrollToHeight) / 2
      else
        documentTextToScrollToTop -= (documentContainerHeight - documentContainerPaneHeadHeight - documentTextToScrollToHeight) / 2
      $documentContainer.stop().animate { scrollTop: documentTextToScrollToTop }, 1000, 'easeInOutQuint'
    else if scrollTheList
      if sameLine
        annotationToScrollToTop -= documentTextToScrollToTop - $documentContainer.scrollTop()
      $annotationContainer.stop().animate { scrollTop: annotationToScrollToTop }, 1000, 'easeInOutQuint'
    else if scrollTheText
      if sameLine
        documentTextToScrollToTop -= annotationToScrollToTop - $annotationContainer.scrollTop()
      $documentContainer.stop().animate { scrollTop: documentTextToScrollToTop }, 1000, 'easeInOutQuint'


  Template.documentDetail.onCreated ->
    if @data.assignmentId
      @assignmentId = @data.assignmentId
      @hitId = @data.hitId
      @workerId = @data.workerId
      @turkSubmitTo = @data.turkSubmitTo
      @userToken = localStorage.getItem 'userToken'
      if not @userToken
        @userToken = Random.id(20)
        localStorage.setItem 'userToken', @userToken
    @subscribe('documentDetail', @data.documentId)
    @subscribe('docAnnotations', @data.documentId, @userToken)
    @subscribe('users', @data.documentId)
    @startOffset = new ReactiveVar()
    @endOffset = new ReactiveVar()
    @annotations = new ReactiveVar()
    @searchText = new ReactiveVar('')
    @searching = new ReactiveVar(false)
    @temporaryAnnotation = new ReactiveVar(new Annotation())
    @selectedAnnotation = new ReactiveVar(id: @data.annotationId, onLoad: true)

  Template.documentDetail.onRendered ->
    instance = Template.instance()
    @autorun ->
      annotations = Annotations.find({documentId: instance.data.documentId}, sort: {startOffset: 1, _id: 0})
      annotations = _.filter annotations.fetch(), (annotation) ->
        CodingKeywords.findOne annotation.codeId

      if instance.searchText.get() is ''
        instance.annotations.set annotations
      else
        searchText = instance.searchText.get().split(' ')
        filteredAnnotations = _.filter annotations, (annotation) ->
          code = CodingKeywords.findOne annotation.codeId
          wordMatches = _.filter searchText, (word) ->
            word = new RegExp(word, 'i')
            code.headerLabel()?.match(word) or code.subHeaderLabel()?.match(word) or code.label?.match(word)
          wordMatches.length
        instance.annotations.set _.sortBy filteredAnnotations, 'startOffset'

    @autorun ->
      selectedAnnotation = instance.selectedAnnotation.get()
      id = selectedAnnotation.id
      if id?
        if selectedAnnotation.noScroll # annotation text click
          highlightText id
          scrollToAnnotation id, false, true, true
        else if selectedAnnotation.onLoad # initial scroll
          if Annotations.findOne id
            setTimeout (->
              highlightText id
              scrollToAnnotation id, true, true, true
            ), 1000
        else # annotation list click
          highlightText id
          scrollToAnnotation id, true, false, true
      else
        highlightText null

  Template.documentDetail.helpers
    document: ->
      Documents.findOne @documentId

    annotations: ->
      Template.instance().annotations.get()

    assignmentId: ->
      Template.instance().assignmentId

    mechanicalTurkPreview: ->
      Template.instance().assignmentId is 'ASSIGNMENT_ID_NOT_AVAILABLE'

    annotationUserEmail: ->
      @userEmail()

    annotationLayers: ->
      temporaryAnnotation = Template.instance().temporaryAnnotation.get()
      annotations = Annotations.find(documentId: @documentId).fetch()
      document = Documents.findOne @documentId
      if temporaryAnnotation.startOffset >= 0
        annotations.push temporaryAnnotation
      annotationLayers = _.map annotations, (annotation) ->
        annotatedBody = document.textWithAnnotation annotation
        Spacebars.SafeString annotatedBody
      annotationLayers

    searching: ->
      Template.instance().searching.get()

  Template.documentDetail.events
    'mousedown .document-container': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      temporaryAnnotation.set startOffset: null, endOffset: null
      instance.temporaryAnnotation.set(temporaryAnnotation)

    # When the document wrapper is clicked, process all document-annotaiton
    # layers that are below the current layer and look for a highlight that
    # would be below the click coordinates.
    'click .document-wrapper': (event, instance) ->
      if not window.getSelection().getRangeAt(0)?.collapsed then return
      x = event.pageX
      y = event.pageY
      documentWrapper = event.currentTarget
      searchIsNotNull = instance.searchText.get() != ''
      childrenCount = documentWrapper.childElementCount
      searchField = document.getElementById 'annotation-search-field'
      hidden = []
      # stash the topmost (text) layer behind annotations
      documentWrapper.firstChild.style.zIndex = -3
      # loop through the annotations
      i = 0
      while i < childrenCount
        elementAtPoint = document.elementFromPoint(x, y)
        if elementAtPoint.nodeName == 'SPAN' # it's span.annotation-highlight
          pointAtAnnotation = ->
            instance.selectedAnnotation.set
              id: elementAtPoint.getAttribute 'data-annotation-id'
              noScroll: true

          if searchIsNotNull
            instance.searchText.set searchField.value = ''
            setTimeout pointAtAnnotation, 400
          else
            pointAtAnnotation()
          break
        else if elementAtPoint.nodeName == 'PRE' # it's pre.document-text
          # hide current annotation layer so we can click the layer below it
          (hidden[i++] = elementAtPoint.parentNode).style.zIndex = -2
        else
          break # clicked through to the documentWrapper

        if i is childrenCount
          instance.selectedAnnotation.set id: null

      # restore z-indices
      none = ''
      documentWrapper.firstChild.style.zIndex = none
      i = 0
      hiddenCount = hidden.length
      while i < hiddenCount
        hidden[i++].style.zIndex = none

    'click .document-detail-container': (event, instance) ->
      instance.startOffset.set null
      instance.endOffset.set null

    'click .document-container': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()

      selection = window.getSelection()
      range = selection.getRangeAt(0)
      selectionInDocument = selection.anchorNode.parentElement.getAttribute('class') == 'document-text'
      textHighlighted = range and (range.endOffset > range.startOffset)

      if selectionInDocument and textHighlighted
        startOffset = range.startOffset
        endOffset = range.endOffset

        temporaryAnnotation.set(startOffset: startOffset, endOffset: endOffset)
        instance.temporaryAnnotation.set(temporaryAnnotation)
        selection.empty()

    'click .code-keyword .selectable-code': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      if temporaryAnnotation.startOffset?
        attributes =
          codeId:      event.currentTarget.getAttribute('data-id')
          documentId:  instance.data.documentId
          startOffset: temporaryAnnotation.startOffset
          endOffset:   temporaryAnnotation.endOffset
        Meteor.call 'createAnnotation', attributes, instance.userToken, (error, response) ->
          if error
            toastr.error("Invalid annotation")
        temporaryAnnotation.set startOffset: null, endOffset: null
        instance.temporaryAnnotation.set temporaryAnnotation

    'input .annotation-search': _.debounce ((e, instance) ->
      searchText = e.target.value
      instance.searchText.set e.target.value
    ), 200

    'input .annotation-search-container .annotation-search': (e, instance) ->
      searchText = e.target.value
      instance.searching.set searchText.length > 0

    'click .annotation-search-container .clear-search': (e, instance) ->
      $('.annotation-search-container .annotation-search')
        .val('')
        .trigger('input')
        .focus()
    'click .finished-annotating': (event, instance) ->
      documentId = instance.data.documentId
      assignmentId = instance.assignmentId
      Meteor.call 'finishAssignment', documentId, assignmentId, (error, submitUrl) ->
        if error
          toastr.error("Unable to finish the annotation")
        else
          form = $('<form method="POST" id="mturkForm">')
          form.attr('action', submitUrl)
          form.submit()

  Template.documentDetailAnnotation.helpers
    header: ->
      @header()

    subHeader: ->
      @subHeader()

    keyword: ->
      @keyword()

    color: ->
      @color()

    code: ->
      header = @header()
      subHeader = @subHeader()
      keyword = @keyword()
      if header and subHeader and keyword
        Spacebars.SafeString("<span class='header'>"+header+"</span> : <span class='sub-header'>"+subHeader+"</span> : <span class='keyword'>"+keyword+"</span>")
      else if subHeader and not keyword
        Spacebars.SafeString("<span class='header'>"+header+"</span> : <span class='sub-header'>"+subHeader+"</span>")
      else if header
        Spacebars.SafeString("<span class='header'>"+header+"</span>")
      else
        ''

    selected: ->
      id = Template.instance().parent().selectedAnnotation.get()?.id
      if @_id is id
        'selected'
      else if id?
        'not-selected'

  Template.documentDetailAnnotation.events
    'click li': (event, instance) ->
      annotationId = instance.data._id
      selectedAnnotation = instance.parent().selectedAnnotation
      if annotationId is selectedAnnotation.get()?.id
        selectedAnnotation.set id: null
      else
        selectedAnnotation.set id: annotationId

    'click li .delete-annotation': (event, instance) ->
      event.stopImmediatePropagation()
      target = event.currentTarget
      $parent = $(target).parent()
      annotationId = instance.data._id
      selectedAnnotation = instance.parent().selectedAnnotation
      $parent.addClass('deleting')
      parentInstance = instance.parent()
      setTimeout (->
        Meteor.call 'deleteAnnotation', annotationId, parentInstance.userToken
      ), 800
      if annotationId is selectedAnnotation.get()?.id
        selectedAnnotation.set id: null

    'click li .toggle-flag': (event, instance) ->
      event.stopImmediatePropagation()
      annotationId = instance.data._id
      Meteor.call 'toggleAnnotationFlag', annotationId


Meteor.methods

  createAnnotation: (attributes, userToken) ->
    @unblock()
    check attributes, Object
    check attributes.documentId, String
    document = Documents.findOne(attributes.documentId)
    if Meteor.isClient
      accessible = true
    else
      group = Groups.findOne(document.groupId)
      user = Meteor.user()
      if user
        accessible = group?.viewableByUser(user)
      else if userToken
        check userToken, String
        if document.mTurkEnabled
          accessible = true
          _userToken = userToken

    if accessible
      annotation = new Annotation()
      annotation.set(attributes)
      annotation.set(userId: @userId)
      if _userToken
        annotation.set(userToken: _userToken)
      if annotation.validate()
        annotation.save()
      else
        annotation.throwValidationException()
    else
      throw new Meteor.Error 'Unauthorized'

  deleteAnnotation: (annotationId, userToken) ->
    @unblock()
    check annotationId, String
    if userToken
      check userToken, String
    annotation = Annotations.findOne(annotationId)
    document = Documents.findOne(annotation.documentId)
    if Meteor.isClient
      accessible = true
    else
      group = Groups.findOne(document.groupId)
      user = Meteor.user()
      if user
        accessible = group?.viewableByUser(user)
      else
        if userToken and document.mTurkEnabled
          accessible = true
          _userToken = userToken

    if accessible
      if _userToken # mTurk
        if annotation.userToken is _userToken
          annotation.remove()
        else
          throw new Meteor.Error 'Not authorized'
      else if user # regular user
        annotation.remove()
    else
      throw new Meteor.Error 'Unauthorized'

  toggleAnnotationFlag: (annotationId) ->
    @unblock()
    check annotationId, String
    annotation = Annotations.findOne annotationId
    document = Documents.findOne annotation.documentId
    if Meteor.isServer
      group = Groups.findOne document.groupId
      user = Meteor.users.findOne @userId
      if user
        accessible = group?.viewableByUser(user)
    else
      accessible = true # reduce the amount of logic on the client side

    if accessible
      annotation.set(flagged: not annotation.flagged)
      annotation.save()
    else
      throw new Meteor.Error 'Unauthorized'


if Meteor.isServer

  Meteor.publish 'documentDetail', (documentId) ->
    check documentId, String
    if @userId
      user = Meteor.users.findOne(@userId)
      document = Documents.findOne(documentId)
      group = Groups.findOne(document.groupId)
      if group?.viewableByUser(user)
        Documents.find(documentId)
      else
        @ready()
    else
      Documents.find(
        _id: documentId
        mTurkEnabled: true
      )

  Meteor.publish 'docAnnotations', (documentId, userToken) ->
    check documentId, String
    if @userId
      document = Documents.findOne(documentId)
      group = Groups.findOne(document.groupId)
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUser(user)
        Annotations.find(documentId: documentId)
      else
        @ready()
    else if userToken
      check userToken, String
      Annotations.find(documentId: documentId, userToken: userToken)
    else
      @ready()

  Meteor.publish 'users', (documentId) ->
    check documentId, String
    if @userId
      document = Documents.findOne documentId
      group = Groups.findOne document.groupId
      Meteor.users.find
        group: group._id
        fields:
          emails: 1
    else
      @ready()

  Meteor.methods
    finishAssignment: (documentId, assignmentId) ->
      @unblock()
      mTurkJob = MTurkJobs.findOne(documentId: documentId)
      if mTurkJob
        mTurkJob.obtainSubmitUrl(assignmentId)
      else
        throw new Meteor.Error('The task has not been found')
