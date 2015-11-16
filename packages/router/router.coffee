if Meteor.isClient
  FlowLayout.setRoot('body')

FlowRouter.subscriptions = () ->
  @register 'userInfo', Meteor.subscribe 'userInfo'

FlowRouter.route '/',
  name: 'splashPage'
  action: () ->
    FlowLayout.render 'layout',
      main: 'splashPage'
      params: {}

FlowRouter.route '/profile/edit',
  name: 'profileEdit'
  action: () ->
    FlowLayout.render 'layout',
      main: 'profileEdit'

FlowRouter.route '/profiles/:_id',
  name: 'profileDetail'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'profileDetail'
      params: {"profileId": params._id}

FlowRouter.route '/documents',
  name: 'documents'
  action: () ->
    FlowLayout.render 'layout',
      main: 'documents'

FlowRouter.route '/admin',
  name: 'admin'
  action: () ->
    FlowLayout.render 'layout',
      main: 'admin'

FlowRouter.route '/editCodingKeywords',
  name: 'editCodingKeywords'
  action: () ->
    FlowLayout.render 'layout',
      main: 'editCodingKeywords'

FlowRouter.route '/documents/new',
  name: 'newDocument'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'documentNew'

FlowRouter.route '/documents/:_id',
  name: 'documentDetail'
  action: (params, query) ->
    FlowLayout.render 'layout',
      main: 'documentDetail'
      params: {"documentId": params._id, "generateCode": query.generateCode}

FlowRouter.route '/documents/:_id/:annotationId',
  name: 'documentDetailWithAnnotation'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'documentDetail'
      params: {"documentId": params._id, "annotationId" : params.annotationId}

FlowRouter.route '/groups/new',
  name: 'newGroup'
  action: () ->
    FlowLayout.render 'layout',
      main: 'groupForm'

FlowRouter.route '/groups/:_id',
  name: 'groupDetail'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'groupDetail'
      params: {"groupId": params._id}

FlowRouter.route '/groups/:_id/randomDocument',
  name: 'randomDocument'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'randomDocument'
      params: {"groupId": params._id}

FlowRouter.route '/groups/:_id/documents',
  name: 'groupDocuments'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'groupDocuments'
      params: {"groupId": params._id}

FlowRouter.route '/codingKeywords',
  name: 'codingKeywords'
  action: () ->
    FlowLayout.render 'layout',
      main: 'codingKeywords'

FlowRouter.route '/annotations',
  name: 'annotations'
  action: () ->
    FlowLayout.render 'layout',
      main: 'annotations'

FlowRouter.route '/reset-password/:token',
  name: 'resetPassword'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'resetPassword'
      params: {"token": params.token}
