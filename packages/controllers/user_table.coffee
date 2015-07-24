if Meteor.isClient

  Template.userTable.filters = () =>
    filters = []
    filters

  Template.userTable.settings = () =>

    fields = []

    fields.push
      key: 'admin'
      label: 'Admin'
      fn:(val, object) ->
        if object.admin
          'Y'
        else
          'N'

    fields.push
      key: 'email'
      label: 'Email'
      fn:(val, object) ->
        object.emails[0].address

    fields.push
      key: "controls"
      label: ""
      hideToggle: true
      fn: (val, obj) ->
        new Spacebars.SafeString("""
          <a class="control remove remove-user" data-id="#{obj._id}" title="Remove">X</a>
        """)

    showColumnToggles: true
    showFilter: false
    fields: fields
    noDataTmpl: Template.noUsers

  Template.userTable.usersCollection = () ->
    Meteor.users.find { group: @groupId }

  Template.userTable.events
    'click .remove-user': (evt) ->
      userId = $(evt.target).data("id")
      reply = prompt('Type "delete" to confirm that this user should be removed.')
      if reply == "delete"
        Meteor.call 'removeUser', userId, (error, response) ->
          if error
            toastr.error("Error")
          else
            toastr.success("User removed")

if Meteor.isServer
  Meteor.methods
    removeUser: (userId) ->
      Meteor.users.remove userId
