if Meteor.isClient

  Template.users.onCreated ->
    @userToDeleteId = new ReactiveVar()
    @userToDeleteEmail = new ReactiveVar()
    @subscribe('userProfiles')


  Template.users.filters = () =>
    filters = []
    filters

  Template.users.settings = () =>

    fields = []

    fields.push
      key: 'email'
      label: 'Email'
      fn: (val, object) ->
        object.emails[0].address

    fields.push
      key: 'group'
      label: 'Group'
      fn: (val, object) ->
        if object.admin
          'Admins'
        else
          Groups.findOne(_id: val)?.name

    fields.push
      key: "controls"
      label: ""
      hideToggle: true
      fn: (val, obj) ->
        new Spacebars.SafeString("""
          <a class="control remove remove-user" data-id="#{obj._id}" data-email="#{obj.emails[0].address}" title="Remove">
            <i class='fa fa-user-times'></>
          </a>
        """)

    showColumnToggles: false
    showFilter: false
    showRowCount: true
    fields: fields
    noDataTmpl: Template.noUsers

  Template.users.usersCollection = () ->
    Meteor.users.find()

  Template.users.helpers
    userToDeleteEmail: ->
      Template.instance().userToDeleteEmail.get()

  Template.users.events
    'click .remove-user': (evt, instance) ->
      userId = $(evt.currentTarget).data("id")
      userEmail = $(evt.currentTarget).data("email")
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

    'click .users-table .reactive-table tr': ->
      profileId = UserProfiles.findOne({userId: @_id})._id
      go 'profileDetail', {_id: profileId}

if Meteor.isServer
  Meteor.methods
    removeUser: (userId) ->
      if Meteor.users.findOne(@userId)?.admin
        Meteor.users.remove userId
      else
        throw 'Unauthorized'

  Meteor.publish 'userProfiles', ->
    UserProfiles.find()
