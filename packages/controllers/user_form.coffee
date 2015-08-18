if Meteor.isClient

  Template.userForm.helpers
    typeIsAdmin: () ->
      Template.instance().data.userType is 'admin'

    groups: () ->
      Groups.find()

    group: () ->
      Template.instance().data.group.get()

  Template.userForm.events

    'submit form': (event, template) ->
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
        groupId: form.group?.value
        admin: template.data.userType is 'admin'
      }

      Meteor.call 'addGroupUser', fields, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Success")
          form.reset()
          $('.modal').modal('hide')

if Meteor.isServer
  Meteor.methods
    addGroupUser: (fields) ->
      if Meteor.user()?.admin
        Accounts.createUser
          email : fields.email
          password : fields.password
          admin: fields.admin
          group: fields.groupId
