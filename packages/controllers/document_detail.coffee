if Meteor.isClient
  $annotationSpanElement = (annotationId) ->
    $(".document-text span[data-annotation-id='#{annotationId}']")

  highlightText = (annotationId) ->
    $(".document-text span").addClass('not-highlighted')
    $annotationSpanElement(annotationId).addClass('highlighted').removeClass('not-highlighted')

  scrollToAnnotation = (annotationId) ->
    annotationToScrollTo = $("ul.annotations li[data-annotation-id='#{annotationId}']")
    annotationListTop = annotationToScrollTo.position()?.top - 85
    $('.annotation-container').animate { scrollTop: annotationListTop }, 1000, 'easeInOutQuint'


  scrollToTextAnnotation = (annotationId, scrollList) ->
    $annotationText = $(".document-text span[data-annotation-id='#{annotationId}']")
    $annotationInList = $("ul.annotations li[data-annotation-id='#{annotationId}']")
    unless scrollList
      $('.document-container').animate { scrollTop: ($annotationText.position().top - $annotationInList.offset().top + ($annotationText.height() / 2) + 45) }, 1000, 'easeInOutQuint'
    else
      annotationDocTop  = $annotationSpanElement(annotationId).position()?.top + 10
      annotationListTop = $annotationInList.position()?.top - 85
      $('.document-container').animate { scrollTop: annotationDocTop }, 1000, 'easeInOutQuint'
      $('.annotation-container').animate { scrollTop: annotationListTop }, 1000, 'easeInOutQuint'

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
      if id
        if selectedAnnotation.noScroll
          highlightText id
          scrollToAnnotation id
        else if selectedAnnotation.onLoad
          if Annotations.findOne id
            setTimeout (->
              highlightText id
              scrollToAnnotation id
              scrollToTextAnnotation id, true
              ), 1000
        else
          highlightText id
          scrollToTextAnnotation id, false

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
      else if id
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
      if selectedAnnotation.get().id is annotationId
        selectedAnnotation.set id: null
        $annotationSpanElement(annotationId).removeClass('highlighted')
        $(".document-annotations span").removeClass('not-highlighted')
      else
        selectedAnnotation.set id: annotationId

    'click .annotation-highlight': (event, instance) ->
      annotationId = event.currentTarget.getAttribute('data-annotation-id')
      instance.selectedAnnotation.set id: annotationId, noScroll: true

    # When the document wrapper is clicked, process all document-annotaiton
    # layers that are below the current layer and look for a highlight that
    # would be below the click coordinates.
    'click .document-wrapper': (event, instance) ->
      # hide the top most layer before we begin processing annotation layers
      $('.document-wrapper > .document-text').hide()
      $('.document-annotations').each () ->
        elementAtPoint = document.elementFromPoint(event.pageX, event.pageY)
        if $(elementAtPoint).hasClass('annotation-highlight')
          $(elementAtPoint).trigger("click")
        if $(elementAtPoint).hasClass('document-text')
          # hide current annotation layer so we can click the layer below it
          $(elementAtPoint).hide()
      #show all the layers we hid
      $('.document-annotations').show()
      $('.document-text').show()

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
        attributes = {}
        attributes['codeId'] = event.currentTarget.getAttribute('data-id')
        attributes['documentId'] = instance.data.documentId
        attributes['startOffset'] = temporaryAnnotation.startOffset
        attributes['endOffset'] = temporaryAnnotation.endOffset
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
      $('.annotation-search-container .annotation-search').val('').trigger('input').focus()

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
    group = Groups.findOne document.groupId
    user = Meteor.users.findOne @userId
    accessible = user and group?.viewableByUser(user)
    if accessible
      annotation = new Annotation()
      annotation.set(attributes)
      annotation.set(userId: @userId)
      annotation.save ->
        document.set("annotated", Annotations.find(documentId: document._id).count())
        document.save()
        annotation
    else
      throw Meteor.Error('Unauthorized')

  deleteAnnotation: (annotationId) ->
    annotation = Annotations.findOne annotationId
    document = Documents.findOne annotation.documentId
    group = Groups.findOne document.groupId
    user = Meteor.users.findOne @userId
    accessibleViaUser = (user and group?.viewableByUser(user))
    if accessibleViaUser
      annotation.remove ->
        document.set("annotated", Annotations.find(documentId: document._id).count())
        document.save()
        annotation
    else
      throw Meteor.Error('Unauthorized')

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
    if @userId
      group = Groups.findOne document.groupId
      user = Meteor.users.findOne @userId
      if group?.viewableByUser(user)
        Annotations.find(documentId: documentId)
      else
        @ready()
    else
      @ready()

  Meteor.publish 'users', (documentId) ->
    if @userId
      document = Documents.findOne documentId
      group = Groups.findOne document.groupId
      Meteor.users.find
        group: group._id
        fields:
          emails: 1
    else
      @ready()
