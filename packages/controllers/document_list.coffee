if Meteor.isClient

  shadowDocuments = new Meteor.Collection null

  Template.documentList.onCreated ->
    @sortBy = new ReactiveVar { createdAt: -1 }
    @searchText = new ReactiveVar ''

    @subscribe 'groups'
    Tracker.autorun =>
      @subscribe 'documents', @data?.group, @searchText.get()

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

    Tracker.autorun ->
      # clean-up no longer existing documents within shadowDocuments
      cleanUpRemovedDocuments()
      # (re-)populate the minimongo collection
      originalDocumentsCursor = Documents.find() # reactive source
      originalDocumentsTotalCount = originalDocumentsCursor.count()
      originalDocumentsArray = originalDocumentsCursor.fetch()
      i = 0
      while i < originalDocumentsTotalCount
        originalDocument = originalDocumentsArray[i]
        newShadowDocument = {}
        newShadowDocument.title = originalDocument.title
        newShadowDocument.lowerTitle = originalDocument.title?.toLowerCase()
        newShadowDocument.createdAt = originalDocument.createdAt
        newShadowDocument.groupId = originalDocument.groupId
        newShadowDocument.annotated = originalDocument.annotated
        # upsert
        if undefined is shadowDocuments.findOne originalDocument._id
          #insert
          newShadowDocument._id = originalDocument._id
          shadowDocuments.insert newShadowDocument
        else
          # update
          shadowDocuments.update originalDocument._id,
            newShadowDocument
        i++
      shadowDocuments


  Template.documentList.helpers
    documents: ->
      instance = Template.instance()
      sortBy = instance.sortBy.get()
      shadowDocuments.find({}, sort: sortBy)
    noDocumentsFound: ->
      Documents.find().count() is 0
    sortBy: (column, order) ->
      instance = Template.instance()
      sortBy = instance.sortBy.get()
      sortBy[column]? and order is sortBy[column]

  Template.documentList.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )
    'input .document-search': _.debounce(( (event, instance)->
      searchQuery = event.currentTarget.value.trim()
      instance.searchText.set searchQuery
    ), 500)
    'click .headers h4': (event, instance) ->
      element = event.currentTarget
      newSortByColumn = element.getAttribute 'data-sort-by'
      currentSortBy = instance.sortBy.get()
      newSortByOrder = 1
      if currentSortBy[newSortByColumn]?
        newSortByOrder = -currentSortBy[newSortByColumn]
      else if currentSortBy[Object.keys(currentSortBy)[0]] < 0
        newSortByOrder *= -1

      newSortObject = {}
      newSortObject[newSortByColumn] = newSortByOrder
      instance.sortBy.set newSortObject

  Template.document.onCreated ->
    @document = new Document(_.pick(@data, _.keys(Document.getFields())))

  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()



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
        if group? and typeof group is 'string'
          query = { groupId: group }
        if searchText? and typeof searchText is 'string'
          query.body =
            $regex: regexEscape(searchText)
            $options: 'i'
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
