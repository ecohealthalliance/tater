if Meteor.isClient

  Template.profileEdit.onCreated ->
    @subscribe('currentUserProfile')

  Template.profileEdit.helpers
    userProfile: ->
      UserProfiles.findOne userId: Meteor.userId()
    email: ->
      Meteor.user().emails[0].address
    countries: ->
      []

  Template.profileEdit.events
    'submit form': (event) ->
      event.preventDefault()
      form = event.target
      if not form.fullName.value or form.fullName.value.length == 0
        toastr.error("A name is required")
        return
      fields = {
        fullName: form.fullName?.value
        jobTitle: form.jobTitle?.value
        bio: form.bio?.value
        emailHidden: form.emailHidden?.checked
      }
      Meteor.call 'updateProfile', fields, (error, response) ->
        if error
          toastr.error("Error")
        else
          toastr.success("Success")


Meteor.methods
  updateProfile: (fields) ->
    userProfile = UserProfiles.findOne userId: Meteor.userId()
    userProfile.update(fields)


if Meteor.isServer

  Meteor.publish 'currentUserProfile', ->
    UserProfiles.find userId: this.userId
