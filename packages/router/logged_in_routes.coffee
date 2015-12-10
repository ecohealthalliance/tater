# Based on the example here:
# https://medium.com/@satyavh/using-flow-router-for-authentication-ba7bb2644f42#.ix98j24rh
loggedIn = FlowRouter.group
  triggersEnter: [ ->
    unless Meteor.loggingIn() or Meteor.userId()
      FlowRouter.go '/'
  ]

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
      params: {"profileId": params._id}

loggedIn.route '/documents',
  name: 'documents'
  action: () ->
    BlazeLayout.render 'layout',
      main: 'documents'

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

loggedIn.route '/documents/new',
  name: 'newDocument'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'documentNew'

loggedIn.route '/documents/:_id',
  name: 'documentDetail'
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'documentDetail'
      params: {"documentId": params._id, "generateCode": query.generateCode}

loggedIn.route '/documents/:_id/:annotationId',
  name: 'documentDetailWithAnnotation'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'documentDetail'
      params: {"documentId": params._id, "annotationId" : params.annotationId}

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
      params: {"groupId": params._id}

loggedIn.route '/groups/:_id/randomDocument',
  name: 'randomDocument'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'randomDocument'
      params: {"groupId": params._id}

loggedIn.route '/groups/:_id/documents',
  name: 'groupDocuments'
  action: (params) ->
    BlazeLayout.render 'layout',
      main: 'groupDocuments'
      params: {"groupId": params._id}

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
  action: () ->
    BlazeLayout.render 'layout',
      main: 'help'