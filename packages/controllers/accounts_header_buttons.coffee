if Meteor.isClient

  Template.accountsHeaderButtons.onCreated ->
    instance = @
    @autorun ->
      instance.subscribe('currentUserName', Meteor.userId())

  Template.accountsHeaderButtons.helpers
    currentUserName: ->
      UserProfiles.findOne({userId: Meteor.userId()})?.fullName or 'Account'

  Template.accountsHeaderButtons.events
    'click .sign-out' : (evt, instance) ->
      Meteor.logout (err) ->
        if err
          throw err
        reloadPage()
        AccountsTemplates.setState('signIn')

    'click .change-password' : (evt, instance) ->
      AccountsTemplates.setState('changePwd')
      @state.set("changePwd")
      $('.accounts-modal').modal('show')



if Meteor.isServer

  Meteor.publish 'currentUserName', (id) ->
    UserProfiles.find({userId: id}, {fields: {userId: 1, fullName: 1}})
