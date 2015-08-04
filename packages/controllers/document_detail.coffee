if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    @showAnnotationForm = new ReactiveVar(false)

  Template.documentDetail.helpers
    'document': ->
      Documents.findOne({ _id: @documentId })

    'showAnnotationForm': ->
      Template.instance().showAnnotationForm.get()

  Template.documentDetail.events
    'mouseup': (event, template) =>
      selection = window.getSelection()

      fullText = selection.anchorNode.data
      range = selection.getRangeAt(0)
      start = range.startOffset
      end = range.endOffset
      length = end - start

      if fullText and (selection.anchorNode.parentElement.id is 'documentBody')
        selectedText = fullText.substr(start, length)
        if start >=0 and end > 0 and start < end
          template.showAnnotationForm.set(true)
        else
          template.showAnnotationForm.set(false)
      else
        template.showAnnotationForm.set(false)

if Meteor.isServer
  Meteor.publish 'documentDetail', (id) ->
    Documents.find id
