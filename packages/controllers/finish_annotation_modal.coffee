if Meteor.isClient
  Template.finishAnnotationModal.onCreated ->
      @addNote = ReactiveVar false

  Template.finishAnnotationModal.helpers
    'addNote': ->
      Template.instance().addNote.get()

  Template.finishAnnotationModal.events
    'click .toggle-add-note': (event, intance) ->
      Template.instance().addNote.set not Template.instance().addNote.get()

    'submit form': (event, instance) ->
      event.preventDefault()
      note = event.target.note?.value
      docId = instance.data.document._id
      Meteor.call 'finishAnnotating', docId, note, (error, response) ->
        if error
          ErrorHelpers.handleError error
        else
          $('#finish-annotation-modal').modal('hide')



Meteor.methods
  'finishAnnotating': (docId, note) ->
    doc = Documents.findOne docId
    doc.finish()
    if note
      doc.set note: note
      doc.save()
