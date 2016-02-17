if Meteor.isServer

  if process.env.ALLOW_TOKEN_ACCESS is 'true'

    email = Meteor.settings.public.accounts?.tokenUser
    token = Meteor.settings.private.accounts?.loginToken

    if token and email
      tokenObject =
        token: token
        when: new Date

      Meteor.startup ->
        if rootUser = Accounts.findUserByEmail email
          Accounts._insertLoginToken(rootUser._id, tokenObject)
