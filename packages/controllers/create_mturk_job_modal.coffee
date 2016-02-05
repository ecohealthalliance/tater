if Meteor.isClient

  Template.createMTurkJobModal.helpers
    defaultTitle: ->
      MTurkJob.getFields().title.default
    defaultDescription: ->
      MTurkJob.getFields().description.default
    defaultLifetimeMinutes: ->
      Math.floor(MTurkJob.getFields().HITLifetimeInSeconds.default / 60)

  Template.createMTurkJobModal.events
    'submit form': (event, instance) ->
      event.preventDefault()
    'click .clear-title': (event, instance) ->
      console.log instance.$('*')
      instance.$('input[name=title]').val('')

    'click .clear-description': (event, instance) ->
      instance.$('textarea[name=description]').val('')

    'click #create-mturk-job': (event, instance) ->
      event.preventDefault()
      form = instance.$('#mturk-job-form')[0]
      fields = {
        documentId: instance.$("#create-mturk-job-modal").data("bs.modal").options.documentId
        title: form.title?.value
        description: form.description?.value
      }
      Meteor.call 'createMTurkJob', fields, (error, response) ->
        if error
          if _.isObject error.reason
            for key, value of error.reason
              toastr.error('Error: ' + value)
          else
            toastr.error('Unknown Error')
        else
          toastr.success('Success')
          $('#create-mturk-job-modal').modal('hide')


if Meteor.isServer

  Meteor.methods
    createMTurkJob: (properties) ->
      check properties, documentId: String
      user = Meteor.user()
      if user?.admin
        fields = {
          documentId: properties.documentId
          userId: user._id
          title: properties.title
          description: properties.description
          rewardAmount: 1
        }
        job = new MTurkJob(fields)
        unless job.validate()
          job.throwValidationException()
        job.save()
        if not job.HITId
          throw new Meteor.Error 'Unable to create Mechanical Turk task'
      else
        throw new Meteor.Error 'Unauthorized'
