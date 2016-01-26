if Meteor.isClient

  @gConnected = true
  @gConnectionErrorText = 'No connection to the server, please try again later'
  setConnected = (online) =>
    @gConnected = not not online

  Template.header.onCreated ->
    @accountsState = new ReactiveVar "signIn"

    tickerId = 0
    reconnectIntervals = [ 3, 10, 15, 30, 60 ] # seconds
    reconnectIntervalStep = 0
    reconnectingIn = 0 # seconds

    s = (amount) -> if amount isnt 1 then 's' else ''
    tock = ->
      if status.status is 'connecting'
        $('#reconnecting-in').text ''
        return
      if reconnectingIn > 0
        $('#reconnecting-in').text """Attempting to reconnect
        in #{reconnectingIn} second#{s(reconnectingIn)}…"""
      else
        Meteor.reconnect()
        $('#reconnecting-in').text ''
        reconnectIntervalStep += 1
        if reconnectIntervalStep >= reconnectIntervals.length
          reconnectIntervalStep = reconnectIntervals.length - 1
        reconnectingIn = reconnectIntervals[reconnectIntervalStep] + 1
      reconnectingIn -= 1

    @autorun ->
      status = Meteor.status()
      setConnected status.connected
      document.body.className = 'now-' + status.status
      if not status.connected
        if not tickerId
          reconnectingIn = reconnectIntervals[reconnectIntervalStep]
          tickerId = setInterval tock, 1000
      else # the connection is back
        clearInterval tickerId
        tickerId = 0
        $('#reconnecting-in').text ''
        reconnectIntervalStep = 0

  Template.header.helpers
    accountsState: -> Template.instance().accountsState

    usingHITId: ->
      window.location.search.match('hitId=')

    documentsLinkParams: ->
      _id: Meteor.user().group

  Template.header.events
    'click #reconnect': (event) ->
      event.preventDefault()
      Meteor.reconnect()

    'click .nav a' : (event) ->
      if $('.navbar-toggle').is(':visible') and
         $('.navbar-collapse').hasClass('in') and
         not $(event.currentTarget).hasClass('dropdown-toggle')
        $('.navbar-collapse').collapse('toggle')

    'click .sign-in' : (event, instance) ->
      instance.accountsState.set("signIn")
      $('.accounts-modal').modal('show')
