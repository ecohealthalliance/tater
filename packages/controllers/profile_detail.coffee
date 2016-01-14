if Meteor.isClient

  Template.profileDetail.onCreated ->
    @subscribe('userProfileDetail', @data.profileId)

  Template.profileDetail.helpers
    userProfile: ->
      UserProfiles.findOne(@profileId)
    itsYou: ->
      userProfile = UserProfiles.findOne(@profileId)
      userProfile?.userId is Meteor.userId()



if Meteor.isServer

  Meteor.publish 'userProfileDetail', (id) ->
    if !@userId then return ready()
    profile = UserProfiles.findOne(id)
    if profile.emailHidden
      UserProfiles.find(id, fields:
        emailAddress: false
      )
    else
      UserProfiles.find(id)
