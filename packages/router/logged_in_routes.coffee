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

FlowRouter.route '/documents/:_id',
  name: 'documentDetail'
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'documentDetail'
      params: {
        "documentId": params._id
        "annotationId": query.annotationId
        "accessToken": query.accessToken
      }

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
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'help'
      params: {'topic': query.topic}

loggedIn.route '/eula',
  name: 'eula'
  action: (params, query) ->
    BlazeLayout.render 'layout',
      main: 'eula'
