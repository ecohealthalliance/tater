if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @subscribe('annotations', @data.documentId)
    @subscribe('users', @data.documentId)
    @subscribe('documentTags', @data.documentId)
    @startOffset = new ReactiveVar()
    @endOffset = new ReactiveVar()
    @selectedAnnotation = new ReactiveVar(null)
    @annotations = new ReactiveVar()
    @searchText = new ReactiveVar('')
    @temporaryAnnotation = new ReactiveVar(new Annotation())
    @showTags = new ReactiveVar(false)

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

    'tags': ->
      DocumentTags.find({documentId: @documentId})

    'showTags': (area) ->
      unless Template.instance().showTags.get()
        if area is 'container'
          'hidden'
      else if area is 'button'
        'showing'

    'availableTags': ->
      DiseaseLabels

    'tagTableSettings': ->
      showColumnToggles: false
      showFilter: true
      fields: [
        {
          key: "label"
          cellClass: "tag-label"
          label: "Tag"
          tmpl: Template.tagCell
        }
      ]


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
        Meteor.call('createAnnotation', attributes)

        temporaryAnnotation.set({startOffset: null, endOffset: null})
        instance.temporaryAnnotation.set(temporaryAnnotation)

    'keyup .annotation-search': _.debounce ((e, instance) -> instance.searchText.set e.target.value), 200

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

    'click .add-tag': ->
      $('.add-tag-modal').modal('show')

    'click .remove-tag': (event, instance)->
        Meteor.call('deleteTag', {
          tag: @tag
          documentId: instance.data.documentId
        })

    'click .tag-label': (event, instance)->
      Meteor.call('createTag', {
        tag: $(event.target).text()
        documentId: instance.data.documentId
      }, (error)->
        if error
          console.log error
          toastr.error("Error:" + error.message)
        else
          toastr.success("Tag Added")
      )

    'click .show-tags': (event, instance) ->
      showTags = instance.showTags
      if showTags.get() then showTags.set(false) else showTags.set(true)

if Meteor.isServer
  Meteor.publish 'documentDetail', (id) ->
    document = Documents.findOne(id)
    if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUser(user)
        Documents.find id
      else
        @ready()
    else
      @ready()

  Meteor.publish 'annotations', (documentId) ->
    document = Documents.findOne(documentId)
    if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUser(user)
        Annotations.find({documentId: documentId})
      else
        @ready()
    else
      @ready()

  Meteor.publish 'documentTags', (documentId) ->
    document = Documents.findOne(documentId)
    if @userId
      group = Groups.findOne({_id: document.groupId})
      user = Meteor.users.findOne(@userId)
      if group?.viewableByUser(user)
        DocumentTags.find({documentId: documentId})
      else
        @ready()
    else
      @ready()

  Meteor.publish 'users', (documentId) ->
    document = Documents.findOne(documentId)
    group = Groups.findOne({_id: document.groupId})
    Meteor.users.find
      group: group._id
      fields:
        emails: 1

  Meteor.methods
    createAnnotation: (attributes) ->
      document = Documents.findOne(attributes.documentId)
      if @userId
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        if group?.viewableByUser(user)
          annotation = new Annotation()
          annotation.set(attributes)
          annotation.set(userId: @userId)
          annotation.save ->
            annotation
        else
          throw 'Unauthorized'
      else
        throw 'Unauthorized'

    deleteAnnotation: (annotationId) ->
      annotation = Annotations.findOne(annotationId)
      document = Documents.findOne(annotation.documentId)
      if @userId
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        if group?.viewableByUser(user)
          annotation.remove() ->
            annotation
        else
          throw 'Unauthorized'
      else
        throw 'Unauthorized'

    createTag: (attributes)->
      document = Documents.findOne(attributes.documentId)
      if @userId
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        if group?.viewableByUser(user)
          if DocumentTags.findOne(attributes)
            throw new Meteor.Error('Tag already exists')
          else
            tag = new DocumentTag()
            tag.set(attributes)
            tag.set(userId: @userId)
            tag.save()
        else
          throw new Meteor.Error('Unauthorized')
      else
        throw new Meteor.Error('Unauthorized')

    deleteTag: (attributes)->
      tag = DocumentTags.findOne(attributes)
      document = Documents.findOne(attributes.documentId)
      if @userId
        group = Groups.findOne({_id: document.groupId})
        user = Meteor.users.findOne(@userId)
        if group?.viewableByUser(user)
          if tag.userId == @userId
            tag.remove()
          else
            throw new Meteor.Error('Unauthorized')
        else
          throw new Meteor.Error('Unauthorized')
      else
        throw new Meteor.Error('Unauthorized')
