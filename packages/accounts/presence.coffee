if Meteor.isClient

  Meteor.subscribe 'userPresence'

  setBrowserToken = (reset) ->
    if reset
      localStorage.removeItem('browserToken')
    else
      if localStorage.getItem('browserToken')
        browserToken = Number localStorage.getItem('browserToken')
      else
        browserToken = Number new Date
        localStorage.setItem('browserToken', browserToken)
        Presence.state = ->
          browserToken
      browserToken

  Meteor.startup ->
    tokenUser = Meteor.settings.public.accounts?.tokenUser
    Meteor.autorun ->
      if userId = Meteor.userId()
        if not Meteor.users.findOne(_id: userId, 'emails.address': tokenUser)
          if Presences.findOne(userId: userId, state: $gt: setBrowserToken())
            setBrowserToken(true)
            Meteor.logout()
            toastr.error 'This account has been used from another browser'
            # Note: $gt will log out the "other" user,
            #       $lt will log out the current one
      else
        setBrowserToken(true)


if Meteor.isServer

  Meteor.publish 'userPresence', () ->
    if this.userId
      # Publish only logged in users
      filter = userId: this.userId

      return Presences.find(filter, { fields: { state: true, userId: true }})
    else
      @ready()
