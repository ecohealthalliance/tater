Meteor.startup ->
  if process.env.ALLOW_TOKEN_ACCESS is 'true'
    if not Groups.findOne(name: "BSVE")
      group = new Group(
        name: "BSVE"
      )
      group.save()
    if CodingKeywords.find().count() == 0
      headerId = Headers.insert
        label: "Disease"
        color: 1
      subHeaderId = SubHeaders.insert
        headerId: headerId
        label: "Fever"
      CodingKeywords.insert
        subHeaderId: subHeaderId
        label: "Ebola Hemorrhagic Fever"
      CodingKeywords.insert
        subHeaderId: subHeaderId
        label: "Dengue Fever"

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
          password: attributes.password
        Meteor.users.update(account, $set: admin: true)
        tokenObject =
          token: token
          when: new Date
        user = Accounts.findUserByEmail(email)
        Accounts._insertLoginToken(user._id, tokenObject)
