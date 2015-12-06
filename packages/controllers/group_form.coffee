if Meteor.isClient
  Template.groupForm.events
    'submit form': (event) ->
      event.preventDefault()
      form = event.target
      fields = {
        name: form.name?.value
        description: form.description?.value
        codeAccessible: form.codeAccessible?.checked
      }
      Meteor.call 'createGroup', fields, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Success")
          go 'admin'


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
