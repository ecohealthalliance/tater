if Meteor.isClient

  Accounts.forgotPassword = (options, callback) ->
    unless options.email
      throw new Error('Please provide an email address')
    Accounts.connection.call('taterForgotPassword', options, callback)


if Meteor.isServer

  Meteor.methods
    taterForgotPassword: (options) ->
      check(options, email: String)

      user = Accounts.findUserByEmail(options.email)
      unless user
        return

      emails = _.pluck(user.emails || [], 'address')
      caseSensitiveEmail = _.find(emails, (email) ->
        email.toLowerCase() is options.email.toLowerCase()
      )

      Accounts.sendResetPasswordEmail(user._id, caseSensitiveEmail)
