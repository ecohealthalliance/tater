# When a bootstrap modal is opened focus on its first input element.
Meteor.startup ->
  $(document).on 'show.bs.modal', (evt)->
    window.setTimeout(->
      # A delay is needed for the input to become visible
      # and the modal animation to end.
      $(evt.target).find('input[type!=hidden], textarea').first().focus()
    , 500)
