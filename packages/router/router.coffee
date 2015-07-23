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

FlowRouter.route '/groups',
  name: 'groups'
  action: () ->
    FlowLayout.render 'layout',
      main: 'groups'

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

FlowRouter.route '/groups/:_id/documents/new',
  name: 'newDocument'
  action: (params) ->
    FlowLayout.render 'layout',
      main: 'documentForm'
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
