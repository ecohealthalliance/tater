if Meteor.isClient
  Template.documentForm.events
    'submit #new-document-form': (event, instance) ->
      event.preventDefault()
      form = event.target
      fields = {
        name: form.title?.value
        description: form.body?.value
        groupId: this.groupId
      }
      Meteor.call 'createDocument', fields, (error, response) =>
        if error
          toastr.error("Error")
        else
          toastr.success("Success")

if Meteor.isServer
  Meteor.methods
    createDocument: (fields) ->
      if this.userId
        document = new Document()
        document.set(fields)
        document.save ->
          document
      else
        throw "Not logged in"
