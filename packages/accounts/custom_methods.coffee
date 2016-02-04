if Meteor.isClient

  Accounts.forgotPassword = (options, callback) ->
    unless options.email
      throw new Error("Must pass options.email")
    Accounts.connection.call("taterForgotPassword", options, callback)

else # Meteor.isServer

  # Method called by a user to request a password reset email. This is
  # the start of the reset process.
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
