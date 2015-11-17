if Meteor.isClient
  Template.groups.onCreated ->
    @subscribe('groups')
    @selectedGroup = new ReactiveVar()

  Template.groups.settings = () =>

    fields = []

    fields.push
      key: 'name'
      label: 'Name'
      fn: (val, object) ->
        object.name

    fields.push
      key: "controls"
      label: "Add User"
      hideToggle: true
      fn: (val, obj) ->
        new Spacebars.SafeString("""
          <a class="control add-user" data-toggle="modal" data-target="#add-group-user-modal">
            <i class='fa fa-user-plus'></>
          </a>
        """)

    showColumnToggles: false
    showFilter: false
    showRowCount: true
    fields: fields
    noDataTmpl: Template.noUsers

  Template.groups.helpers
    groups: ->
      if Meteor.userId()
        Groups.find({}, sort: name: 1)
    group: ->
      Template.instance().selectedGroup

  Template.groups.events
    'click .add-user': (event, template) ->
      template.selectedGroup.set(@)
    
    'click .groups-table .reactive-table tr': ->
      go 'groupDocuments', {_id: @_id}

if Meteor.isServer
  Meteor.publish 'groups', ->
    user = Meteor.users.findOne { _id: @userId }
    if user?.admin
      Groups.find {}
    else if user
      Groups.find {_id: user.group }
    else
      @ready()
