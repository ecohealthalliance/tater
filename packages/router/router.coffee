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

# Based on the example here:
# https://medium.com/@satyavh/using-flow-router-for-authentication-ba7bb2644f42
requireLoggedIn = ->
  unless Meteor.loggingIn() or Meteor.userId()
    FlowRouter.go '/'
loggedIn = FlowRouter.group
  triggersEnter: [
    requireLoggedIn
    @requireEula
  ]

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
      params: {'token': params.token}

FlowRouter.route '/enroll-account/:token',
  name: 'enrollAccount'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'enrollAccount'
      params: {'token': params.token}

FlowRouter.route '/register',
  name: 'register'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'register'
      params: {}

loggedIn.route '/profile/edit',
  name: 'profileEdit'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'profileEdit'

loggedIn.route '/profiles/:_id',
  name: 'profileDetail'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'profileDetail'
      params: {'profileId': params._id}

loggedIn.route '/documents',
  name: 'documents'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'documents'

loggedIn.route '/documents/new',
 name: 'newDocument'
 action: (params) ->
   BlazeLayout.render 'layout',
     main: 'documentNew'

FlowRouter.route '/documents/:_id',
 name: 'documentDetail'
 action: (params, query) ->
   BlazeLayout.render 'layout',
     main: 'documentDetail'
     params: {
       'documentId': params._id
       'annotationId': query.annotationId
       'assignmentId': query.assignmentId
       'hitId': query.hitId
       'workerId': query.workerId
       'turkSubmitTo': query.turkSubmitTo
     }

FlowRouter.route '/authenticate',
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'splashPage'
      params: {}
    Meteor.startup ->
      Meteor.loginWithToken(query.bsveAccessKey);

loggedIn.route '/admin',
  name: 'admin'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'admin'

loggedIn.route '/editCodingKeywords',
  name: 'editCodingKeywords'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'editCodingKeywords'

loggedIn.route '/groups/new',
  name: 'newGroup'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'groupForm'

loggedIn.route '/groups/:_id',
  name: 'groupDetail'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'groupDetail'
      params: {'groupId': params._id}

loggedIn.route '/groups/:_id/randomDocument',
  name: 'randomDocument'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'randomDocument'
      params: {'groupId': params._id}

loggedIn.route '/groups/:_id/documents',
  name: 'groupDocuments'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'groupDocuments'
      params: {'groupId': params._id}

loggedIn.route '/codingKeywords',
  name: 'codingKeywords'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'codingKeywords'

loggedIn.route '/annotations',
  name: 'annotations'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'annotations'

loggedIn.route '/help',
  name: 'help'
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'help'
      params: {'topic': query.topic}

loggedIn.route '/eula',
  name: 'eula'
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'eula'
