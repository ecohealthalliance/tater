if Meteor.isClient
  Template.userForm.events
    'submit form': (event) ->
      event.preventDefault()
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
