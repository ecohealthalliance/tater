UserProfiles = new Mongo.Collection('userProfile')
UserProfile = Astro.Class
  name: 'UserProfile'
  collection: UserProfiles
  fields:
    userId: 'string'
    firstName: 'string'
    middleName: 'string'
    lastName: 'string'
    jobTitle: 'string'
    bio: 'string'
    emailHidden: 'boolean'
    emailAddress: 'string'
    phoneNumber: 'string'
    address1: 'string'
    address2: 'string'
    city: 'string'
    state: 'string'
    zip: 'string'
    country: 'string'
  behaviors: ['timestamp']

  methods:
    update: (fields, callback) ->
      filteredFields = _.pick(fields, 'firstName', 'middleName', 'lastName',
                              'jobTitle', 'bio', 'emailHidden', 'phoneNumber',
                              'address1', 'address2', 'city', 'state', 'zip',
                              'country')
      this.set(filteredFields)
      this.save ->
        callback?()



if Meteor.isServer

  Accounts.onCreateUser (options, user) ->
    profile = new UserProfile()
    profile.set
      userId: user._id
      firstName: user.firstName
      middleName: user.middleName
      lastName: user.lastName
      emailAddress: user.emails[0].address
      emailHidden: true
    profile.save(-> {})
    user.admin = options.admin
    user.group = options.group
    user
