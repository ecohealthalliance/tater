DocumentListPages = new Meteor.Pagination Documents,
  perPage: 10,
  templateName: 'documentList'
  itemTemplate: 'document'
  availableSettings:
    perPage: true
    filters: true
  auth: (skip, subscription)->
    [QueryHelpers.userDocsQuery(Meteor.users.findOne({_id: subscription.userId}))]

# Based on bobince's regex escape function.
# source: http://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711
regexEscape = (s)->
  s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

if Meteor.isClient

  Template.documentList.onCreated ->
    instance = Template.instance()
    instance.group = @data?.group
    if instance.group
      DocumentListPages.set
        filters:
          groupId: @data.group._id
    else
      @subscribe('groups')
    @searchString = instance.data.searchString
    @searchResultsCount = new ReactiveVar()


  Template.documentList.onRendered ->
    instance = Template.instance()
    @autorun ->
      searchString = instance.searchString.get()
      filters =
        title:
          $regex: regexEscape(searchString)
          $options: 'i'
      if instance.group
        filters.groupId = instance.group._id
      DocumentListPages.set(filters:filters)
      DocumentListPages.sess("currentPage", 1)
      instance.searchResultsCount.set DocumentListPages.Collection.find().count()

  Template.documentList.helpers
    thereAreDocuments: ->
      not DocumentListPages.isEmpty

  Template.documentList.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )

  Template.document.onCreated ->
    @document = new Document(_.pick(@data, _.keys(Document.getFields())))
  Template.document.helpers
    groupName: ->
      Template.instance().document.groupName()
