if Meteor.isClient
  BlazeLayout.setRoot('body')

FlowRouter.subscriptions = () ->
  @register 'userInfo', Meteor.subscribe 'userInfo'

eulaTracker = null
@requireEula = (context)->
  if context.route.name == 'eula'
    return
  eulaTracker?.stop()
  # Autorun is needed to wait for the user profile to become available.
  # if the user profile is available they are sent to the EULA
  # if they have not accepted it.
  eulaTracker = Tracker.autorun ->
    user = Meteor.user()
    # Check for admin property because the user object might exist with missing
    # properties at first.
    if user and !_.isUndefined(user.admin)
      if user.acceptedEULA
        eulaTracker?.stop()
      else
        FlowRouter.go 'eula'

FlowRouter.route '/',
  name: 'splashPage'
  triggersEnter: [
    requireEula
  ]
  action: () ->
    BlazeLayout.render 'layout',
      main: 'splashPage'
      params: {}

FlowRouter.route '/reset-password/:token',
  name: 'resetPassword'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'resetPassword'
      params: {"token": params.token}

FlowRouter.route '/enroll-account/:token',
  name: 'enrollAccount'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'enrollAccount'
      params: {"token": params.token}

FlowRouter.route '/register',
  name: 'register'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'register'
      params: {}
