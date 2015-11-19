DocumentsPages = new Meteor.Pagination Documents, 
  perPage: 10,
  templateName: 'documents'
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

  Template.documents.helpers
    thereAreDocuments: ->
      not DocumentsPages.isEmpty

  Template.documents.events
    'click .delete-document-button': (event) ->
      $('#confirm-delete-document').attr(
        "data-document-id",
        event.target.parentElement.getAttribute("data-document-id")
      )
    'keyup .document-search': _.debounce(((event, instance)->
      DocumentsPages.set
        filters: 
          title:
            $regex: regexEscape($(event.currentTarget).val())
            $options: 'i'
    ), 500)