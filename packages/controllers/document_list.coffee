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
        if undefined is Documents.findOne shadowDocument._id
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
        # upsert
        if undefined is shadowDocuments.findOne originalDocument._id
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
      i = 0
      while i < totalPages
        returnArray[i++] = { number: i, active: currentPageNumber is i }
      returnArray
    multiplePages: ->
      Template.instance().numberOfPages.get() > 1

  Template.documentList.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )
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

  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()

  Template.documentListPages.events
    'click a': (event, instance) ->
      event.preventDefault()
      pageNumber = Number event.currentTarget.innerText
      if $(event.currentTarget).parent().is(':first-child')
        pageNumber = 1
      else if $(event.currentTarget).parent().is(':last-child')
        pageNumber = instance.parent().numberOfPages.get()
      Template.instance().parent().currentPageNumber.set pageNumber



if Meteor.isServer

  # Based on bobince's regex escape function.
  # source: http://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711
  regexEscape = (s)->
    s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

  fields = { title: true, createdAt: true, groupId: true, annotated: true }

  Meteor.publish 'documents', (group, searchText)->
    if @userId?
      user = Meteor.users.findOne @userId
      if user.admin? # the current user is an admin
        query = {}
        if group? and 'string' is typeof group
          query = { groupId: group }
        if searchText? and typeof searchText is 'string'
          query.$or = [ body: {
              $regex: regexEscape(searchText)
              $options: 'i'
            },
            title: {
              $regex: regexEscape(searchText)
              $options: 'i'
            } ]
        Documents.find query, fields: fields
      else # normal user
        query = { group: user.group }
        if group? and typeof group is 'string'
          if user.group != group
            @ready()
        if searchText? and typeof searchText is 'string'
          query.body =
            $regex: regexEscape(searchText)
            $options: 'i'
        Documents.find query, fields: fields
    else
      @ready()
