if Meteor.isClient
  BlazeLayout.setRoot('body')

FlowRouter.subscriptions = () ->
  @register 'userInfo', Meteor.subscribe 'userInfo'

FlowRouter.route '/',
  name: 'splashPage'
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
