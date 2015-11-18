GroupPages = new Meteor.Pagination Documents, 
  perPage: 10,
  templateName: 'groupDocuments',
  itemTemplate: 'groupDocument',
  availableSettings:
    perPage: true,
    filters: true
  auth: (skip, subscription)->
    [QueryHelpers.userDocsQuery(Meteor.users.findOne({_id: subscription.userId}))]

if Meteor.isClient
  Template.groupDocuments.onCreated ->
    GroupPages.set
      filters: 
        groupId: @data.groupId
    @subscribe('groupDocuments', @data.groupId)

  Template.groupDocuments.helpers
    group: ->
      Groups.findOne(@groupId)

    documents: ->
      Documents.find({}, {groupId: @groupId})

    newDocumentParams: ->
      _id: @groupId

    showNewDocumentLink: ->
      group = Groups.findOne(@groupId)
      group.viewableByUser(Meteor.user())

  Template.groupDocuments.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr("data-document-id", event.target.parentElement.getAttribute("data-document-id"))

if Meteor.isServer
  Meteor.publish 'groupDocuments', (id) ->
    user = Meteor.users.findOne(@userId)
    group = Groups.findOne(id)

    if user and group?.viewableByUser(user)
      [
        Groups.find(id)
        Groups.findOne(id).documents()
      ]