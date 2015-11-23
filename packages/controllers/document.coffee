if Meteor.isClient

  Template.document.helpers
    annotationStateIcon: ->
      if @annotated
        'adjust'
      else
        'circle-o'
