if Meteor.isClient

  Template.users.onCreated ->
    @userToDeleteId = new ReactiveVar()
    @userToDeleteEmail = new ReactiveVar()
    @selectedGroup = new ReactiveVar()
    @subscribe('userProfiles')

  Template.users.helpers
    settings: ->
      fields = []

      fields.push
        key: 'email'
        label: 'Email'

      fields.push
        key: 'group'
        label: 'Group'

      fields.push
        key: "controls"
        label: ""
        hideToggle: true
        fn: (val, obj) ->
          new Spacebars.SafeString("""
            <a class="control remove remove-user" data-id="#{obj.userId}" data-email="#{obj.email}" title="Remove">
              <i class='fa fa-user-times'></>
            </a>
          """)

      showColumnToggles: false
      showFilter: true
      showRowCount: true
      fields: fields
      noDataTmpl: Template.noUsers

    usersCollection: ->
      users = new Meteor.Collection null
      Meteor.users.find().forEach (user)->
        if user.admin
          group = 'Admins'
        else
          group = Groups.findOne(_id: user.group)?.name
        users.insert
          email: user.emails[0].address
          group: group
          userId: user._id
      users

    userToDeleteEmail: ->
      Template.instance().userToDeleteEmail.get()
    selectedGroup: ->
      Template.instance().selectedGroup

  Template.users.events
    'click .users-container .add-admin': (event, template) ->
      template.selectedGroup.set null

    'click .remove-user': (event, instance) ->
      event.stopPropagation()
      userId = $(event.currentTarget).data("id")
      userEmail = $(event.currentTarget).data("email")
      instance.userToDeleteId.set(userId)
      instance.userToDeleteEmail.set(userEmail)
      $('#remove-user-modal').modal('show')

    'click .confirm-remove-user': (event, instance) ->
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
      profileId = UserProfiles.findOne({userId: @userId})._id
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
