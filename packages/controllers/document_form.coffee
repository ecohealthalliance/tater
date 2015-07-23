if Meteor.isClient
  Template.documentForm.events
    'submit #new-document-form': (event, instance) ->
      event.preventDefault()
      form = event.target
      fields = {
        title: form.title?.value
        body: form.body?.value
        groupId: @groupId
      }
      Meteor.call 'createDocument', fields, (error, response) =>
        if error
          toastr.error("Error")
        else
          toastr.success("Success")
          go "documents", {_id: @groupId}

if Meteor.isServer
  Meteor.methods
    createDocument: (fields) ->
      if @userId
        group = Groups.findOne({_id: fields.groupId})
        user = Meteor.user()
        if group?.editableByUserWithGroup(user.group)
          document = new Document()
          document.set(fields)
          document.save ->
            document
        else
          throw "Unauthorized"
      else
        throw "Not logged in"
