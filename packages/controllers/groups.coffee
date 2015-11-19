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
        new Spacebars.SafeString("""
          <span class="group-detail" data-id="#{object._id}">
            """+object.name+"""
          </span>
        """)

    fields.push
      key: "controls"
      label: ""
      hideToggle: true
      fn: (val, obj) ->
        new Spacebars.SafeString("""
          <a class="control add-user" data-toggle="modal" data-target="#add-group-user-modal" data-group="#{obj._id}">
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
    'click .groups-table .add-user': (event, template) ->
      template.selectedGroup.set $(event.currentTarget).data("group")

    'click span.group-detail': (event, template) ->
      docID = $(event.currentTarget).data("id")
      go 'groupDocuments', {_id: docID}

if Meteor.isServer
  Meteor.publish 'groups', ->
    user = Meteor.users.findOne { _id: @userId }
    if user?.admin
      Groups.find {}
    else if user
      Groups.find {_id: user.group }
    else
      @ready()
