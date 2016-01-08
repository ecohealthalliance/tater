if Meteor.isClient

  Template.userForm.onRendered ->
    $("[data-toggle='tooltip']").tooltip
      placement: 'bottom'
      container: 'body'
      trigger: 'hover'
      delay:
        'show': 500
        'hide': 100

  Template.userForm.helpers
    typeIsAdmin: () ->
      !Template.instance().data.group.get()?

    groups: () ->
      Groups.find()

    group: () ->
      Template.instance().data.group.get()

  Template.userForm.events
    'click .user-group': (event, template) ->
      showGroups = event.target.id == "group"
      $(".groups").toggleClass('hidden',!showGroups)

    'submit form': (event, template) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      form = event.target
      if not form.email.value or form.email.value.trim() is ''
        toastr.error("An email address is required")
        return
      if not form.first.value or form.first.value.trim() is ''
        toastr.error("First name is required")
        return
      if not form.last.value or form.last.value.trim() is ''
        toastr.error("Last name is required")
        return
      if form.password.value != form.passwordconfirm.value
        toastr.error("Password mismatch")
        return
      groupId = null
      if $(".document_groups").is(":visible")
        groupId = $(".document_groups").val()
      else
        groupId = form.group?.value

      fields = {
        email: form.email.value
        password: form.password.value
        groupId: groupId
        admin:  !groupId     #if no group provided then user is admin
        firstName: form.first.value
        lastName: form.last.value
      }

      Meteor.call 'addUser', fields, (error, response) ->
        if error
          toastr.error("Error")
          console.log error
        else
          toastr.success("Success")
          form.reset()
          $('.modal').modal('hide')



if Meteor.isServer

  Meteor.methods
    addUser: (fields) ->
      if Meteor.user()?.admin
        userId = Accounts.createUser
          email:    fields.email
          password: fields.password
          admin:    fields.admin
          group:    fields.groupId
        #update the profile to include first/last name
        userProfile = UserProfiles.findOne(userId: userId)
        userProfile.update
          firstName: fields.firstName
          lastName:  fields.lastName
        Accounts.sendEnrollmentEmail(userId)
