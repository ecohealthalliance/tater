if Meteor.isClient

  Template.connectionStatus.onCreated ->
    tickerId = 0
    reconnectIntervals = [ 3, 10, 15, 30, 60 ] # seconds
    reconnectIntervalStep = 0
    reconnectingIn = 0 # seconds

    pluralize = (unit, amount) -> if amount isnt 1 then "#{unit}s" else unit
    tock = ->
      if status.status is 'connecting'
        $('.reconnecting-in').text ''
        return
      if reconnectingIn > 0
        $('.reconnecting-in').text """Attempting to reconnect
        in #{reconnectingIn} #{pluralize("second", reconnectingIn)}…"""
      else
        Meteor.reconnect()
        $('.reconnecting-in').text ''
        reconnectIntervalStep += 1
        if reconnectIntervalStep >= reconnectIntervals.length
          reconnectIntervalStep = reconnectIntervals.length - 1
        reconnectingIn = reconnectIntervals[reconnectIntervalStep] + 1
      reconnectingIn -= 1

    @autorun ->
      if Meteor.user()
        status = Meteor.status()
        if not status.connected
          document.body.classList.add('not-connected')
          if not tickerId
            reconnectingIn = reconnectIntervals[reconnectIntervalStep]
            tickerId = setInterval tock, 1000
        else # the connection is back
          clearInterval tickerId
          tickerId = 0
          $('.reconnecting-in').text ''
          reconnectIntervalStep = 0
          document.body.classList.remove('not-connected')

  Template.connectionStatus.helpers
    connected: ->
      Meteor.status().connected

  Template.connectionStatus.events
    'click .reconnect': (event) ->
      event.preventDefault()
      Meteor.reconnect()
