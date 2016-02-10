if Meteor.isServer

  token = Meteor.settings.private.accounts?.loginToken
  email = Meteor.settings.private.accounts?.rootUserEmail

  if token and email
    tokenObject =
      token: token
      when: new Date

    func = ->
      rootUser = Accounts.findUserByEmail email
      if rootUser
        Accounts._insertLoginToken(rootUser._id, tokenObject)
        true
      false

    Meteor.startup ->
      if not func()
        handle = Meteor.users.find()
        handle.observeChanges
          added: func
