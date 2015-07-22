if Meteor.isClient
  Template.userForm.events
    'submit form': (event) ->
      event.preventDefault()
      form = event.target
      fields = {
        email: form.email.value
        password: form.password.value
        groupId: form.groupId.value
        admin: form.admin.value is 'true'
      }
      Meteor.call 'addGroupUser', fields, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Success")
