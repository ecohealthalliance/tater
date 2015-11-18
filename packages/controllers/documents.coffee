DocumentsPages = new Meteor.Pagination Documents, 
  perPage: 10,
  templateName: 'documents'
  itemTemplate: 'document'
  availableSettings:
    perPage: true
  auth: (skip, subscription)->
    [QueryHelpers.userDocsQuery(Meteor.users.findOne({_id: subscription.userId}))]

if Meteor.isClient

  Template.documents.helpers
    thereAreDocuments: ->
      not DocumentsPages.isEmpty

  Template.documents.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )
