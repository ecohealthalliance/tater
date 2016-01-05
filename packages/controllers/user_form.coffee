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
      if not form.email.value or form.email.value.length == 0
        toastr.error("An email address is required")
        return
      if not form.name.value or form.name.value.length == 0
        toastr.error("A name is required")
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
        fullName: form.name.value
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
          email : fields.email
          password : fields.password
          admin: fields.admin
          group: fields.groupId
        #update the profile to include full name
        userProfile = UserProfiles.findOne({userId: userId})
        userProfile.update(fullName: fields.fullName)
        Accounts.sendEnrollmentEmail(userId)
