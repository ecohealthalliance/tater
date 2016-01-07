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
    profile = new UserProfile()
    profile.set({userId: user._id, emailAddress: user.emails[0].address, fullName: user.fullName})
    profile.save(-> {})
    user.admin = options.admin
    user.group = options.group
    user
