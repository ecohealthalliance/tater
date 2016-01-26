if Meteor.isClient
  Template.createMTurkJobModal.helpers
    defaultTitle: ->
      MTurkJob.getFields().title.default
    defaultDescription: ->
      MTurkJob.getFields().description.default
    defaultLifetimeMinutes: ->
      Math.floor(MTurkJob.getFields().HITLifetimeInSeconds.default / 60)

  Template.createMTurkJobModal.events
    'click .clear-title': (event) ->
      $('input[name=title]').val('')

    'click .clear-description': (event) ->
      $('textarea[name=description]').val('')

    'click #create-mturk-job': (event, instance) ->
      event.preventDefault()
      form = instance.$('#mturk-job-form')[0]
      if form.lifetimeMinutes?.value
        lifetimeSeconds = form.lifetimeMinutes?.value * 60
      fields = {
        docId: instance.$("#create-mturk-job-modal").data("bs.modal").options.documentId
        title: form.title?.value
        description: form.description?.value
        HITLifetimeInSeconds: lifetimeSeconds
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
