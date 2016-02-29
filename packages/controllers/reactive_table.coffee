if Meteor.isClient
  Template.reactiveTable.onRendered ->
    parentName = @parent().view.name.slice(9)
    @$('.reactive-table-options .reactive-table-input').attr 'placeholder', "Search #{parentName}"
