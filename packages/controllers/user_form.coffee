if Meteor.isClient
  Template.userForm.onCreated () ->
    @isAdmin = new ReactiveVar(false)

  Template.userForm.helpers
    isAdmin: () ->
      Template.instance().isAdmin.get()

    groups: () ->
      Groups.find()

  Template.userForm.events
    'change #user-admin': (event, template) ->
      isAdmin = !template.isAdmin.get()
      template.isAdmin.set(isAdmin)
      event.stopImmediatePropagation()

    'submit form': (event) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      if not form.email.value or form.email.value.length == 0
        toastr.error("An email address is required")
        return
      if form.password.value != form.passwordconfirm.value
        toastr.error("Password mismatch")
        return

      fields = {
        email: form.email.value
        password: form.password.value
        groupId: form.group.value
        admin: form.admin.checked
      }
      Meteor.call 'addGroupUser', fields, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Success")
          form.reset()

if Meteor.isServer
  Meteor.methods
    addGroupUser: (fields) ->
      if Meteor.user()?.admin
        Accounts.createUser
          email : fields.email
          password : fields.password
          admin: fields.admin
          group: fields.groupId
