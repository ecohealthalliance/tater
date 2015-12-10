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
      event.preventDefault()
      $(event.target).parent().addClass('active')
      $('html,body').animate
        scrollTop:
          $(event.target.hash).offset().top
        ,'slow'
      $('.help-nav-wrap').scrollspy('refresh')
