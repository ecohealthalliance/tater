if Meteor.isClient

  perPage = 10
  shadowDocuments = new Meteor.Collection null

  Template.documentList.onCreated ->
    @sortBy = new ReactiveVar
      createdAt: -1
      title: 'Date Created'
    @searchText = new ReactiveVar ''
    @numberOfPages = new ReactiveVar 1
    @currentPageNumber = new ReactiveVar 1

    @subscribe 'groups'
    Tracker.autorun =>
      @subscribe 'documents', @data?.group?._id, @searchText.get()

    cleanUpRemovedDocuments = ->
      i = 0
      shadowDocumentsCursor = shadowDocuments.find()
      shadowDocumentsTotalCount = shadowDocumentsCursor.count()
      shadowDocumentsArray = shadowDocumentsCursor.fetch()
      while i < shadowDocumentsTotalCount
        shadowDocument = shadowDocumentsArray[i]
        if Documents.findOne(shadowDocument._id) is undefined
          shadowDocuments.remove shadowDocument._id
        i++

    Tracker.autorun =>
      # clean-up no longer existing documents within shadowDocuments
      cleanUpRemovedDocuments()
      # (re-)populate the minimongo collection
      originalDocumentsCursor = Documents.find() # reactive source
      originalDocumentsTotalCount = originalDocumentsCursor.count()
      originalDocumentsArray = originalDocumentsCursor.fetch()
      i = 0
      while i < originalDocumentsTotalCount
        originalDocument = originalDocumentsArray[i++]
        newShadowDocument = {}
        newShadowDocument.title = originalDocument.title
        newShadowDocument.lowerTitle = originalDocument.title?.toLowerCase()
        newShadowDocument.createdAt = originalDocument.createdAt
        newShadowDocument.groupId = originalDocument.groupId
        newShadowDocument.annotated = originalDocument.annotated
        newShadowDocument.groupName = originalDocument.groupName()
        newShadowDocument.mTurkEnabled = originalDocument.mTurkEnabled
        # upsert
        if shadowDocuments.findOne(originalDocument._id) is undefined
          #insert
          newShadowDocument._id = originalDocument._id
          shadowDocuments.insert newShadowDocument
        else
          # update
          shadowDocuments.update originalDocument._id,
            newShadowDocument
      # update the amount of pages
      @numberOfPages.set Math.ceil i / perPage
      # reset the currently selected page number to 1
      @currentPageNumber.set 1


  Template.documentList.helpers
    documents: ->
      instance = Template.instance()
      sortBy = instance.sortBy.get()
      amountToSkip = (instance.currentPageNumber.get() - 1) * perPage
      shadowDocuments.find({}, sort: sortBy, limit: perPage, skip: amountToSkip)

    noDocumentsFound: ->
      Documents.find().count() is 0

    sortBy: (column, order) ->
      instance = Template.instance()
      sortBy = instance.sortBy.get()
      sortBy[column]? and order is sortBy[column]

    sortByTitle: ->
      Template.instance().sortBy.get().title

    sortByColumn: ->
      _.keys(Template.instance().sortBy.get())[0]

    sortDirection: (order) ->
      _.values(Template.instance().sortBy.get())[0] is order

    pages: ->
      instance = Template.instance()
      totalPages = instance.numberOfPages.get()
      currentPageNumber = instance.currentPageNumber.get()
      returnArray = []
      visiblePagingLimit = 10 # max number of visible paging buttons
      skip = 0
      i = 0
      p = 1
      if totalPages > visiblePagingLimit # overflow
        visiblePagingHalfLimit = Math.floor(visiblePagingLimit / 2)
        # left ellipsis
        if currentPageNumber > visiblePagingHalfLimit + 1 # skip the first two
          returnArray.push null # left ...
          i++
          skip = currentPageNumber - visiblePagingHalfLimit
          if totalPages - currentPageNumber <= visiblePagingHalfLimit
            skip -= visiblePagingHalfLimit - (totalPages - currentPageNumber) - 1 + Math.ceil(visiblePagingLimit % 2)
          p += skip
      while i < visiblePagingLimit and p <= totalPages
        i++
        if i == visiblePagingLimit and totalPages - p # it's the last cycle
          returnArray.push null # right ...
          break
        returnArray.push { number: p, active: currentPageNumber is p }
        p++
      returnArray

    multiplePages: ->
      Template.instance().numberOfPages.get() > 1

  Template.documentList.events

    'input .document-search': _.debounce(( (event, instance)->
      searchQuery = $(event.currentTarget).val().trim()
      instance.searchText.set searchQuery
    ), 500)
    'click .document-sorting-options .column, click .current-sorting': (event, instance) ->
      event.preventDefault()
      element = event.currentTarget
      newSortByColumn = element.getAttribute 'data-sort-by'
      newSortByColumnTitle = element.getAttribute 'data-title'
      currentSortBy = instance.sortBy.get()
      newSortByOrder = 1
      if currentSortBy[newSortByColumn]?
        newSortByOrder = -currentSortBy[newSortByColumn]
      else if currentSortBy[Object.keys(currentSortBy)[0]] < 0
        newSortByOrder *= -1

      newSortObject = {}
      newSortObject[newSortByColumn] = newSortByOrder
      newSortObject['title'] =  newSortByColumnTitle
      instance.sortBy.set newSortObject
      $(element).blur()

  Template.document.onCreated ->
    @document = new Document(_.pick(@data, _.keys(Document.getFields())))
    @docOptionsShowing = new ReactiveVar false

  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()

    annotatedTitle: ->
      "#{@annotated} annotations"

    showing: ->
      if Template.instance().docOptionsShowing.get()
        'active'
    hideInfo: ->
      if Template.instance().docOptionsShowing.get()
        'hide-info'

  Template.document.events
    'click .doc-options': (event) ->
      event.preventDefault()

    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )

    'mouseover .doc-options-wrap': (event, instance) ->
      instance.docOptionsShowing.set true

    'mouseout .doc-options-wrap': (event, instance) ->
      instance.docOptionsShowing.set false


  Template.documentListPages.events
    'click a': (event, instance) ->
      event.preventDefault()
      pageNumber = Number event.currentTarget.innerText
      if $(event.currentTarget).parent().is(':first-child')
        pageNumber = 1
      else if $(event.currentTarget).parent().is(':last-child')
        pageNumber = instance.parent().numberOfPages.get()
      if pageNumber
        Template.instance().parent().currentPageNumber.set pageNumber


if Meteor.isServer

  # Based on bobince's regex escape function.
  # source: http://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711
  regexEscape = (s)->
    s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

  fields = { title: true, createdAt: true, groupId: true, annotated: true }

  Meteor.publish 'documents', (group, searchText)->
    if @userId
      user = Meteor.users.findOne @userId
      query = {}

      if user.admin # the current user is an admin
        if group
          check group, String
          query = { groupId: group }
      else # normal user
        query = { groupId: user.group }
        if group
          check group, String
          if user.group != group
            @ready()

      if searchText
        check searchText, String
        query.$or = [ body: {
            $regex: regexEscape(searchText)
            $options: 'i'
          },
          title: {
            $regex: regexEscape(searchText)
            $options: 'i'
          } ]

      Documents.find query, fields: fields
    else
      @ready()
