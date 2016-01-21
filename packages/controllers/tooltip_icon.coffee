if Meteor.isClient

  Template.tooltipIcon.onRendered ->
    $('[data-toggle=tooltip]').tooltip
      container: 'body'
      delay:
        show: 100
        hide: 250

  Template.tooltipIcon.helpers
    title: ->
      @title or 'Go to help page for more info.'

  Template.tooltipIcon.events
    'click i': (event) ->
      $(event.target).tooltip('hide')
