if Meteor.isServer

  token = Meteor.settings.private.accounts?.loginToken
  email = Meteor.settings.private.accounts?.rootUserEmail

  if token and email
    tokenObject =
      token: token
      when: new Date

    Meteor.startup ->
      rootUser = Accounts.findUserByEmail email
      if rootUser
        Accounts._insertLoginToken(rootUser._id, tokenObject)
