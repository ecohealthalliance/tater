if Meteor.isClient
  Template.documentForm.onCreated ->
    @subscribe 'groups'

  Template.documentForm.helpers
    groups: ->
      Groups.find({}, { sort: { name: 1 } })

  Template.documentForm.events
    'submit #new-document-form': (event, instance) ->
      event.preventDefault()
      form = event.target
      fields = {
        title: form.title?.value.trim()
        body: form.body?.value.trim()
      }
      currentUser = Meteor.user()
      if currentUser.admin
        fields.groupId = form.groupId?.value
      else
        fields.groupId = currentUser.group

      Meteor.call 'createDocument', fields, (error, response) ->
        if error
          if error.reason
            for key, value of error.reason
              toastr.error('Error: ' + value)
          else
            toastr.error('Unknown Error')
        else
          toastr.success('Success')
          go 'documentDetail', { _id: response }



Meteor.methods
  createDocument: (fields) ->
    unless fields.groupId
      throw new Meteor.Error('Required', ['A document group has not been selected'])
    if @userId
      group = Groups.findOne fields.groupId
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
        throw new Meteor.Error('Unauthorized')
    else
      throw new Meteor.Error('Not logged in')
