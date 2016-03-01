if Meteor.isClient

  Template.documentNoteModal.events
    'submit form': (event, instance) ->
      event.preventDefault()
      note = event.target.note?.value
      docId = instance.data.document._id
      if note
        Meteor.call 'addDocumentNote', docId, note, (error, response) ->
          if error
            toastr.error("Error: #{error.message}")
          else

            $('#document-note-modal').modal('hide')
      else
        toastr.error("Please enter a note.")


Meteor.methods
  'addDocumentNote': (docId, note) ->
    Documents.update docId,
      $set:
        note: note
