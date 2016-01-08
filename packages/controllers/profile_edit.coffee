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
      if not form.firstName.value or form.firstName.value.trim() is ''
        toastr.error("First name is required")
        return
      if not form.lastName.value or form.lastName.value.trim() is ''
        toastr.error("Last name is required")
        return
      fields = {
        firstName: form.firstName?.value
        middleName: form.middleName?.value
        lastName: form.lastName?.value
        jobTitle: form.jobTitle?.value
        bio: form.bio?.value
        emailHidden: form.emailHidden?.checked
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
