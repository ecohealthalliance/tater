Meteor.startup ->
  if process.env.ALLOW_TOKEN_ACCESS is 'true'
    console.log 'Tater started in BSVE mode'
    if not Groups.findOne(name: "BSVE")
      group = new Group(
        name: "BSVE"
      )
      group.save()
    unless CodingKeywords.find().count()
      colorId = 0
      for H, Header of BSVEinitialData
        colorId = colorLoop(colorId++)
        headerId = Headers.insert
          label: H
          color: colorId
        for SH, SubHeader of Header
          subHeaderId = SubHeaders.insert
            headerId: headerId
            label: SH
          for Keyword in SubHeader
            CodingKeywords.insert
              subHeaderId: subHeaderId
              label: Keyword

    email = Meteor.settings.public.accounts?.tokenUser
    token = Meteor.settings.private.accounts?.loginToken

    if token and email
      tokenObject =
        token: token
        when: new Date

      if rootUser = Accounts.findUserByEmail(email)
        Accounts._insertLoginToken(rootUser._id, tokenObject)
      else
        account = Accounts.createUser
          email: email
        Meteor.users.update(account, $set: admin: true, acceptedEULA: true)
        tokenObject =
          token: token
          when: new Date
        user = Accounts.findUserByEmail(email)
        Accounts._insertLoginToken(user._id, tokenObject)
