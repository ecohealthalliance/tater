if Meteor.isClient

  Retina
    retinajs: true
    attribute : 'data-retina'

  scrollToElement = (element, delay = 0) ->
    setTimeout ( ->
      $('html,body').animate
        scrollTop:
          $(element).offset().top
        , 'slow'
      ), delay

  Template.help.onRendered ->
    topic = Template.instance().data.topic
    if topic
      scrollToElement("##{topic}", 100)
    $("body").scrollspy({target: ".help-nav-wrap"})
    $('.help-nav').affix
      offset:
        top: $('.help-nav').offset().top - 20

  Template.help.events
    'click .help-nav li a': (event) ->
      event.preventDefault()
      $(event.target).parent().addClass('active')
      scrollToElement(event.target.hash)
      $('.help-nav-wrap').scrollspy('refresh')
