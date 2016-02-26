if Meteor.isClient
  Template.userModal.helpers
    selectedGroup: ->
      Template.instance().data.group
