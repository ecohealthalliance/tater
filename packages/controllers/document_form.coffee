if Meteor.isClient
  Template.documentForm.onCreated ->
    @subscribe 'groups'

  Template.documentForm.helpers
    groups: ->
      Groups.find({})

  Template.documentForm.events
    'submit #new-document-form': (event, instance) ->
      event.preventDefault()
      form = event.target
      fields = {
        title: form.title?.value
        body: form.body?.value
      }
      currentUser = Meteor.user()
      if currentUser.admin
        fields.groupId = form.groupId?.value
      else
        fields.groupId = currentUser.group

      Meteor.call 'createDocument', fields, (error, response) =>
        if error
          console.log error
          if error.reason
            for key, value of error.reason
              toastr.error("Error: " + value)
          else
            toastr.error("Unknown Error")
        else
          toastr.success("Success")
          go 'documentDetail', {_id: response}

if Meteor.isServer
  Meteor.methods
    createDocument: (fields) ->
      if @userId
        group = Groups.findOne({_id: fields.groupId})
        user = Meteor.user()
        if group?.viewableByUser(user)
          document = new Document()
          document.set(fields)

          if document.validate()
            document.save ->
              document
          else
            document.throwValidationException()
        else
          throw "Unauthorized"
      else
        throw "Not logged in"
