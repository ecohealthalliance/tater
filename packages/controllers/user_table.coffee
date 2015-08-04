if Meteor.isClient

  Template.userTable.onCreated ->
    @userToDeleteId = new ReactiveVar()
    @userToDeleteEmail = new ReactiveVar()

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
          <a class="control remove remove-user" data-id="#{obj._id}" data-email="#{obj.emails[0].address}" title="Remove">X</a>
        """)

    showColumnToggles: true
    showFilter: false
    fields: fields
    noDataTmpl: Template.noUsers

  Template.userTable.usersCollection = () ->
    Meteor.users.find { group: @groupId }

  Template.userTable.helpers
    userToDeleteEmail: ->
      Template.instance().userToDeleteEmail.get()

  Template.userTable.events
    'click .remove-user': (evt, instance) ->
      userId = $(evt.target).data("id")
      userEmail = $(evt.target).data("email")
      instance.userToDeleteId.set(userId)
      instance.userToDeleteEmail.set(userEmail)
      $('#remove-user-modal').modal('show')

    'click .confirm-remove-user': (evt, instance) ->
      userId = instance.userToDeleteId.get()
      Meteor.call 'removeUser', userId, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("User removed")
        $('#remove-user-modal').modal('hide')
        instance.userToDeleteId.set(null)
        instance.userToDeleteEmail.set(null)

if Meteor.isServer
  Meteor.methods
    removeUser: (userId) ->
      if Meteor.users.findOne(@userId)?.admin
        Meteor.users.remove userId
      else
        throw 'Unauthorized'
