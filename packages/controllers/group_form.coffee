if Meteor.isClient
  Template.groupForm.events
    'submit form': (event) ->
      event.preventDefault()
      form = event.target
      fields = {
        name: form.name?.value.trim()
        description: form.description?.value.trim()
      }
      Meteor.call 'createGroup', fields, (error, response) ->
        if error
          if error.reason
            for key, value of error.reason
              toastr.error('Error: ' + value)
          else
            toastr.error('Unknown Error')
        else
          toastr.success("Success")
          $('#add-group-modal').modal('hide')


Meteor.methods
  createGroup: (fields) ->
    if @userId
      group = new Group()
      group.set(fields)
      group.set('createdById', @userId)
      if group.validate()
          group.save ->
            group
      else
        group.throwValidationException()
    else
      throw new Meteor.Error('Not logged in')
