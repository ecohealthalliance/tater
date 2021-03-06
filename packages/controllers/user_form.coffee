if Meteor.isClient

  Template.userForm.onCreated ->
    @subscribe('groups')

  Template.userForm.helpers
    typeIsAdmin: () ->
      not Template.instance().data.group.get()?

    groups: () ->
      Groups.find()

    group: () ->
      Groups.findOne(Template.instance().data.group.get())

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
      if not form.name.value or form.name.value.trim() is ''
        toastr.error("A name is required")
        return
      groupId = null
      if $(".document_groups").is(":visible")
        groupId = $(".document_groups").val()
      else
        groupId = form.group?.value

      fields = {
        email: form.email.value
        groupId: groupId
        admin:  !groupId     #if no group provided then user is admin
        fullName: form.name.value
      }

      Meteor.call 'addUser', fields, (error, response) ->
        if error
          ErrorHelpers.handleError error
        else
          toastr.success("Success")
          form.reset()
          if $(".document_groups").is(":visible")
            $('#admin').prop('checked', true)
          $('.modal').modal('hide')



if Meteor.isServer

  Meteor.methods
    addUser: (fields) ->
      if Meteor.user()?.admin
        userId = Accounts.createUser
          email:    fields.email
          admin:    fields.admin
          group:    fields.groupId
        #update the profile to include full name
        userProfile = UserProfiles.findOne(userId: userId)
        userProfile.update
          fullName: fields.fullName
        Accounts.sendEnrollmentEmail(userId)
