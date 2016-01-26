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
      if not gConnected then return toastr.error gConnectionErrorText
      form = event.target
      if not form.fullName.value or form.fullName.value.trim() is ''
        toastr.error("Full name is required")
        return
      fields = {
        fullName: form.fullName?.value
        jobTitle: form.jobTitle?.value
        bio: form.bio?.value
        phoneNumber: form.phoneNumber?.value
        address1: form.address1?.value
        address2: form.address2?.value
        city: form.city?.value
        state: form.state?.value
        zip: form.zip?.value
        country: form.country?.value
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
