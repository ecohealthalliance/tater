if Meteor.isClient
  Template.groupForm.events
    'submit form': (event) ->
      event.preventDefault()
      form = event.target
      fields = {
        name: form.name?.value
        description: form.description?.value
      }
      Meteor.call 'createGroup', fields, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Success")

if Meteor.isServer
  Meteor.methods
    createGroup: (fields) ->
      if this.userId
        group = new Group()
        group.set(fields)
        group.set('createdById', this.userId)
        group.save ->
          group
      else
        throw "Not logged in"

    addGroupUser: (fields) ->
      if Meteor.user()?.admin
        Accounts.createUser
          email : email
          password : password
          admin: admin
          group: groupId
