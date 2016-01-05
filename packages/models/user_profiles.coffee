UserProfiles = new Mongo.Collection('userProfile')
UserProfile = Astro.Class
  name: 'UserProfile'
  collection: UserProfiles
  fields:
    fullName: 'string'
    jobTitle: 'string'
    bio: 'string'
    emailHidden: 'boolean'
    userId: 'string'
    emailAddress: 'string'
  behaviors: ['timestamp']

  methods:
    update: (fields, callback) ->
      filteredFields = _.pick(fields, 'fullName', 'jobTitle', 'bio', 'emailHidden')
      this.set(filteredFields)
      this.save ->
        callback?()



if Meteor.isServer

  Accounts.onCreateUser (options, user) ->
    # email the user his/her password
    Email.send
      to:      user.emails[0].address,
      from:    "\"Tater Accounts\" <no-reply@tater.io>",
      subject: "Welcome to Tater!",
      text:    "Hello.\n\nYour password is " + options.password

    profile = new UserProfile()
    profile.set({userId: user._id, emailAddress: user.emails[0].address})
    profile.save(-> {})
    user.admin = options.admin
    user.group = options.group
    user
