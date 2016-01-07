if Meteor.isClient

  $annotationSpanElement = (annotationId) ->
    $ ".document-text span[data-annotation-id='#{annotationId}']"

  highlightText = (annotationId) ->
    $(".document-text span").addClass('not-highlighted')
    $annotationSpanElement(annotationId)
      .addClass('highlighted')
      .removeClass('not-highlighted')

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
    @subscribe('documentDetail', @data.documentId)
    @subscribe('docAnnotations', @data.documentId)
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

    accessCode: ->
      Template.instance().accessCode

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

    header: ->
      @header()

    subHeader: ->
      @subHeader()

    keyword: ->
      @keyword()

    color: ->
      @color()

    code: ->
      if @header() and @subHeader() and @keyword()
        Spacebars.SafeString("<span class='header'>#{@header()}</span> : <span class='sub-header'>#{@subHeader()}</span> : <span class='keyword'>#{@keyword()}</span>")
      else if @subHeader() and not @keyword()
        Spacebars.SafeString("<span class='header'>#{@header()}</span> : <span class='sub-header'>#{@subHeader()}</span>")
      else if @header()
        Spacebars.SafeString("<span class='header'>"+@header()+"</span>")
      else
        ''

    selected: ->
      id = Template.instance().selectedAnnotation.get()?.id
      if @_id is id
        'selected'
      else if id?
        'not-selected'

    searching: ->
      Template.instance().searching.get()

  Template.documentDetail.events
    'mousedown .document-container': (event, instance) ->
      temporaryAnnotation = instance.temporaryAnnotation.get()
      temporaryAnnotation.set startOffset: null, endOffset: null
      instance.temporaryAnnotation.set(temporaryAnnotation)

    'click .annotations li': (event, template) ->
      annotationId = event.currentTarget.getAttribute('data-annotation-id')
      selectedAnnotation = template.selectedAnnotation
      if selectedAnnotation.get()?.id is annotationId
        selectedAnnotation.set id: null
        $annotationSpanElement(annotationId).removeClass('highlighted')
        $(".document-annotations span").removeClass('not-highlighted')
      else
        selectedAnnotation.set id: annotationId

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

        if i is 1
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
        Meteor.call 'createAnnotation', attributes, (error, response) ->
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

    'click .delete-annotation': (event, instance) ->
      event.stopImmediatePropagation()
      target = event.currentTarget
      annotationId = target.getAttribute('data-annotation-id')
      $(target).parent().addClass('deleting')
      setTimeout (->
        Meteor.call 'deleteAnnotation', annotationId
        if annotationId is instance.selectedAnnotation.get()
          $(".document-annotations span").removeClass('not-highlighted')
      ), 800

    'click .toggle-flag': (event, instance) ->
      event.stopImmediatePropagation()
      target = event.currentTarget
      annotationId = target.getAttribute('data-annotation-id')
      Meteor.call('toggleAnnotationFlag', annotationId)



Meteor.methods

  createAnnotation: (attributes) ->
    document = Documents.findOne attributes.documentId
    if Meteor.isServer
      group = Groups.findOne document.groupId
      user = Meteor.users.findOne @userId
      accessibleViaUser = user? and group?.viewableByUser(user)
    else
      accessibleViaUser = true
    if accessibleViaUser
      annotation = new Annotation()
      annotation.set(attributes)
      annotation.set(userId: @userId)
      if annotation.validate()
        annotation.save()
      else
        annotation.throwValidationException()
    else
      throw new Meteor.Error 'Unauthorized'

  deleteAnnotation: (annotationId) ->
    annotation = Annotations.findOne annotationId
    document = Documents.findOne annotation.documentId
    if Meteor.isServer
      group = Groups.findOne document.groupId
      user = Meteor.users.findOne @userId
      accessibleViaUser = user? and group?.viewableByUser(user)
    else
      accessibleViaUser = true
    if accessibleViaUser
      annotation.remove()
    else
      throw new Meteor.Error 'Unauthorized'

  toggleAnnotationFlag: (annotationId) ->
    annotation = Annotations.findOne annotationId
    annotation.set(flagged: not annotation.flagged)
    annotation.save()



if Meteor.isServer

  Meteor.publish 'documentDetail', (id) ->
    document = Documents.findOne id
    if @userId
      group = Groups.findOne document.groupId
      user = Meteor.users.findOne @userId
      if group?.viewableByUser(user)
        Documents.find id
      else
        @ready()
    else
      @ready()

  Meteor.publish 'docAnnotations', (documentId) ->
    document = Documents.findOne documentId
    if @userId?
      group = Groups.findOne document.groupId
      user = Meteor.users.findOne @userId
      if group?.viewableByUser(user)
        Annotations.find(documentId: documentId)
      else
        @ready()
    else
      @ready()

  Meteor.publish 'users', (documentId) ->
    if @userId?
      document = Documents.findOne documentId
      group = Groups.findOne document.groupId
      Meteor.users.find
        group: group._id
        fields:
          emails: 1
    else
      @ready()
