if Meteor.isClient

  Retina
    retinajs: true
    attribute : 'data-retina'

  Template.help.onRendered ->
    $('body').attr('data-spy', 'scroll').attr('data-target', '.help-nav-wrap')
    $('.help-nav').affix
      offset:
        top: $('.help-nav').offset().top - 20

  Template.help.events
    'click .help-nav li a': (event) ->
      console.log event.target.hash

      event.preventDefault()
      $('html,body').animate
        scrollTop:
          $(event.target.hash).offset().top
        ,'slow'
      $('.help-nav-wrap').scrollspy('refresh')
