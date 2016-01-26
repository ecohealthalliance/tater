if Meteor.isClient
  Template.eula.events
    'click .accept-eula': (event) ->
      if not gConnected then return toastr.error gConnectionErrorText
      Meteor.call 'acceptEULA', (error, response) ->
        if error
          toastr.error("Error")
        else
          go '/'

if Meteor.isServer
  Meteor.methods
    acceptEULA: ->
      if @userId
        Meteor.users.update({_id: @userId}, {$set: {'acceptedEULA': true}})
      else
        throw new Meteor.Error("Not logged in")
