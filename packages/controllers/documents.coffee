if Meteor.isClient

  Template.documents.onCreated ->
    @searchString = new ReactiveVar('')

  Template.documents.helpers
    searchString: ->
      Template.instance().searchString

  Template.documents.events
    'keyup .document-search': _.debounce(((event, instance)->
        instance.searchString.set $(event.currentTarget).val()
      ), 500)

