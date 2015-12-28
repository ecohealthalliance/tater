DocumentListPages = new Meteor.Pagination Documents,
  perPage: 10,
  templateName: 'documentList'
  itemTemplate: 'document'
  sort:
    createdAt: -1
  availableSettings:
    sort: true
    # perPage: true
    filters: true
  auth: (skip, subscription)->
    # Meteor pagination auth functions break filtering.
    # I am using a work around based on the approach here:
    # https://github.com/alethes/meteor-pages/issues/131
    user = Meteor.users.findOne subscription.userId
    if not user then return false
    userSettings = @userSettings[subscription._session.id] or {}
    userFilters = userSettings.filters or @filters
    userFields = userSettings.fields or @fields
    userSort = userSettings.sort or @sort
    userPerPage = userSettings.perPage or @perPage
    [
      {
        $and: [
          userFilters
          QueryHelpers.userDocsQuery(user)
        ]
      },
      {
        fields: userFields
        sort: userSort
        limit: userPerPage
        skip: skip
      }
    ]

# Based on bobince's regex escape function.
# source: http://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711
regexEscape = (s)->
  s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

if Meteor.isClient

  window.DocumentListPages = DocumentListPages
  Template.documentList.onCreated ->
    instance = Template.instance()
    instance.group = @data?.group
    instance.sortBy = new ReactiveVar 2 # 1 = group, 2 = date, -3 = annotated desc
    if instance.group?
      DocumentListPages.set
        filters:
          groupId: @data.group._id
    else
      DocumentListPages.set
        filters: {}
      @subscribe('groups')

    Tracker.autorun ->
      sortBy = instance.sortBy.get()
      sortObj = {}
      keyName = 'createdAt'
      switch Math.abs(sortBy)
        when 1 then keyName = 'groupId'
        when 3 then keyName = 'annotated'
      sortObj[keyName] = if sortBy < 0 then -1 else 1
      DocumentListPages.set
       sort: sortObj


  Template.documentList.helpers
    noDocumentsFound: ->
      DocumentListPages.Collection.find().count() == 0 and DocumentListPages.isReady()
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
    'click .document-list-sort span a': (event, instance) ->
      element = event.currentTarget
      newSortBy = Number element.getAttribute 'data-sort-by'
      currentSortBy = instance.sortBy.get()
      if currentSortBy is newSortBy
        newSortBy *= -1
      instance.sortBy.set(newSortBy)

  Template.document.onCreated ->
    @document = new Document(_.pick(@data, _.keys(Document.getFields())))

  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()
