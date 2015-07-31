getDocument = (documentId) ->
  console.log '@', @
  console.log 'document',Documents.findOne { _id: documentId }
  Documents.findOne { _id: documentId }

if Meteor.isClient

  Template.documentDetail.onCreated ->
    @subscribe('documentDetail', @data.documentId)
    Session.set 'showAnnotationForm', false

  Template.documentDetail.helpers
    'document': () -> getDocument(@documentId)

    'showAnnotationForm': () ->
      Session.get 'showAnnotationForm'

  Template.layout.created = () ->
    $(window).on 'mouseup', () ->
      selection = window.getSelection()

      fullText = selection.anchorNode.data
      range = selection.getRangeAt(0)
      start = range.startOffset
      end = range.endOffset
      length = end - start

      if fullText and (selection.anchorNode.parentElement.id is 'documentBody')
        selectedText = fullText.substr(start, length)
        if start >=0 and end > 0 and start < end
          Session.set 'showAnnotationForm', true
        else
          Session.set 'showAnnotationForm', false
      else
        Session.set 'showAnnotationForm', false

if Meteor.isServer
  Meteor.publish 'documentDetail', (id) ->
    Documents.find id
