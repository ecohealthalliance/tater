if Meteor.isClient

  Template.createMTurkJobModal.helpers
    defaultTitle: ->
      Template.instance().mechanicalTurkJob.title
    defaultDescription: ->
      Template.instance().mechanicalTurkJob.description
    cost: ->
      dollars = Template.instance().mechanicalTurkJob.costInCents() / 100
      "$#{dollars}"

  Template.createMTurkJobModal.onCreated ->
    @mechanicalTurkJob = new MTurkJob()

  Template.createMTurkJobModal.events
    'submit form': (event, instance) ->
      event.preventDefault()
    'click .clear-title': (event, instance) ->
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
      check properties, documentId: String, title: String, description: String
      user = Meteor.user()
      if MTurkJobs.findOne(paymentFailed: true)
        throw new Meteor.Error """
        Your last charge could not be processed so you cannot create more
        mechanical turk jobs.
        Please email tater-bugs@ecohealthalliance.org to resolve your payment problems.
        """
      if user?.admin
        fields = {
          documentId: properties.documentId
          title: properties.title
          description: properties.description
          userId: user._id
        }
        job = new MTurkJob(fields)
        unless job.validate()
          job.throwValidationException()
        job.save()
        if not job.HITId
          throw new Meteor.Error 'Unable to create Mechanical Turk task'
      else
        throw new Meteor.Error 'Unauthorized'
