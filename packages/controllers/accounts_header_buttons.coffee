if Meteor.isClient

  Template.accountsHeaderButtons.onCreated ->
    instance = @
    @autorun ->
      instance.subscribe('currentUserName', Meteor.userId())

  Template.accountsHeaderButtons.helpers
    currentUserName: ->
      UserProfiles.findOne({userId: Meteor.userId()})?.firstName or 'Account'

  Template.accountsHeaderButtons.events
    'click .sign-out' : (evt, instance) ->
      Meteor.logout (err) ->
        if err
          throw err
        reloadPage()
    'click .change-password' : (evt, instance) ->
      @state.set("changePwd")
      $('.accounts-modal').modal('show')



if Meteor.isServer

  Meteor.publish 'currentUserName', (id) ->
    UserProfiles.find({userId: id}, {fields: {userId: 1, firstName: 1, middleName: 1, lastName: 1}})
