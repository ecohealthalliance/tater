if Meteor.isClient
  Template.userTable.filters = () =>
    console.log '@data', @data
    filters = []
    filters

  Template.userTable.settings = () =>

    console.log 'in settings'

    showColumnToggles: true
    showFilter: false
    fields: {key: 'email', label: 'Email'}
    noDataTmpl: 'noUsers'
