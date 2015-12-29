# Based on bobince's regex escape function.
# source: http://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711
regexEscape = (s)->
  s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

if Meteor.isClient

  shadowDocuments = new Meteor.Collection null

  Template.documentList.onCreated ->
    instance = Template.instance()
    instance.group = @data?.group
    instance.sortBy = new ReactiveVar -2 # 1 = title, -2 = date, 3 = annotated

    @subscribe 'groups', =>
      @subscribe 'documents'

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
      sortObj = {}
      keyName = 'createdAt'
      switch Math.abs(sortBy)
        when 1 then keyName = 'lowerTitle'
        when 3 then keyName = 'annotated'
      sortObj[keyName] = if sortBy < 0 then -1 else 1
      shadowDocuments.find({}, sort: sortObj)
    noDocumentsFound: ->
      Documents.find().count() is 0
    sortBy: (index) ->
      index is Template.instance().sortBy.get()

  Template.documentList.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )
    'keyup .document-search': _.debounce(((event, instance)->
      searchText = $(event.currentTarget).val()
      filters =
        title:
          $regex: regexEscape(searchText)
          $options: 'i'
      if instance.group
        filters.groupId = instance.group._id
      DocumentListPages.set(filters:filters)
      DocumentListPages.sess("currentPage", 1)
    ), 500)
    'click .headers h4': (event, instance) ->
      element = event.currentTarget
      newSortBy = Number element.getAttribute 'data-sort-by'
      currentSortBy = instance.sortBy.get()
      if Math.abs(currentSortBy) is newSortBy
        newSortBy = -currentSortBy
      else if currentSortBy < 0
        newSortBy *= -1
      instance.sortBy.set(newSortBy)

  Template.document.onCreated ->
    @document = new Document(_.pick(@data, _.keys(Document.getFields())))

  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()



if Meteor.isServer

  fields = { title: true, createdAt: true, groupId: true, annotated: true }

  Meteor.publish 'documents', ->
    if @userId?
      user = Meteor.users.findOne @userId
      if user.admin?
        Documents.find {}, fields: fields
      else
        Documents.find { group: user.group }, fields: fields
    else
      @ready()
