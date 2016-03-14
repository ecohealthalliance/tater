if Meteor.isServer

  # RFC822 regex email validation
  RFC822 = new RegExp /^([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22))*\x40([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d))*$/

  # returns true if the input string represents an email address
  isValidEmail = (string) ->
    RFC822.test string

  Meteor.methods
    createDefaultUser: (email) ->
      check email, String

      if Meteor.users.find().count() < 1
        if isValidEmail email
          newUserId = Accounts.createUser
            email: email
            admin: true
          Accounts.sendEnrollmentEmail(newUserId)
        else
          throw new Meteor.Error 'invalid', 'Please provide a valid email'
      else
        throw new Meteor.Error 'invalid', 'The system already has users'
