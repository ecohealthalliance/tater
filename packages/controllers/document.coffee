if Meteor.isClient
  Template.document.onRendered ->
    $('.annotation-state i').tooltip()
