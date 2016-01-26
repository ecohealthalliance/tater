if Meteor.isClient

  Template.users.onCreated ->
    @userToDeleteId = new ReactiveVar()
    @userToDeleteEmail = new ReactiveVar()
    @subscribe('userProfiles')

  Template.users.helpers
    filters: ->
      filters = []
      filters
    settings: ->
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
    usersCollection: ->
      Meteor.users.find()
    userToDeleteEmail: ->
      Template.instance().userToDeleteEmail.get()

  Template.users.events
    'click .remove-user': (event, instance) ->
      event.stopPropagation()
      userId = $(event.currentTarget).data("id")
      userEmail = $(event.currentTarget).data("email")
      instance.userToDeleteId.set(userId)
      instance.userToDeleteEmail.set(userEmail)
      $('#remove-user-modal').modal('show')

    'click .confirm-remove-user': (event, instance) ->
      if not gConnected then return toastr.error gConnectionErrorText
      userId = instance.userToDeleteId.get()
      Meteor.call 'removeUser', userId, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("User removed")
        $('#remove-user-modal').modal('hide')
        instance.userToDeleteId.set(null)
        instance.userToDeleteEmail.set(null)

    'click .users-table .reactive-table tbody tr': ->
      profileId = UserProfiles.findOne({userId: @_id})._id
      go 'profileDetail', {_id: profileId}


Meteor.methods
  removeUser: (userId) ->
    if Meteor.users.findOne(@userId)?.admin
      Meteor.users.remove userId
    else
      throw new Meteor.Error 'Unauthorized'


if Meteor.isServer
  Meteor.publish 'userProfiles', ->
    UserProfiles.find()
