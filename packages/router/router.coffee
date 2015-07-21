if Meteor.isClient
  FlowLayout.setRoot('body');

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
