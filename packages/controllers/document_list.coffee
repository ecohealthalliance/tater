DocumentListPages = new Meteor.Pagination Documents,
  perPage: 10,
  templateName: 'documentList'
  itemTemplate: 'document'
  sort:
    createdAt: -1
  availableSettings:
    perPage: true
    filters: true
  auth: (skip, subscription)->
    # Meteor pagination auth functions break filtering.
    # I am using a work around based on the approach here:
    # https://github.com/alethes/meteor-pages/issues/131
    user = Meteor.users.findOne({_id: subscription.userId})
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
          QueryHelpers.userDocsQuery(
            user,
            { showCodeAccessible: Boolean(userFilters.groupId) })
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
    if instance.group
      DocumentListPages.set
        filters:
          groupId: @data.group._id
    else
      DocumentListPages.set
        filters: {}
      @subscribe('groups')

  Template.documentList.helpers
    noDocumentsFound: ->
      DocumentListPages.Collection.find().count() == 0 and DocumentListPages.isReady()

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

  Template.document.onCreated ->
    @document = new Document(_.pick(@data, _.keys(Document.getFields())))

  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()
