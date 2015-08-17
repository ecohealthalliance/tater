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
        body: form.body?.value?.replace(/\t/g, "    ")
      }
      currentUser = Meteor.user()
      if currentUser.admin
        fields.groupId = form.groupId?.value
      else
        fields.groupId = currentUser.group

      Meteor.call 'createDocument', fields, (error, response) =>
        if error
          toastr.error("Error")
        else
          toastr.success("Success")
          if currentUser.admin
            go 'documents'
          else
            go 'groupDocuments', {_id: currentUser.group}

if Meteor.isServer
  Meteor.methods
    createDocument: (fields) ->
      if @userId
        group = Groups.findOne({_id: fields.groupId})
        user = Meteor.user()
        if group?.viewableByUser(user)
          document = new Document()
          document.set(fields)
          document.save ->
            document
        else
          throw "Unauthorized"
      else
        throw "Not logged in"
