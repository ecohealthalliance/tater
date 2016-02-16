if Meteor.isClient
  Template.admin.onCreated ->
    @subscribe('groups')
    @selectedGroup = new ReactiveVar()

  Template.admin.helpers
    selectedGroup: ->
      Template.instance().selectedGroup

  Template.admin.events
    'click .groups-table .add-user': (event, template) ->
      template.selectedGroup.set Groups.findOne({_id: $(event.currentTarget).data("group")})

    'click .users-container .add-admin': (event, template) ->
      template.selectedGroup.set null