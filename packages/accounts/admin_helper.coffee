if Meteor.isClient
  UI.registerHelper 'isAdmin', () ->
    Meteor.user()?.admin

  UI.registerHelper 'onBSVEInstance', () ->
    # Check whether a login token is defined in settings.json to determine
    # whether this is a BSVE instance.
    "loginToken" of Meteor.settings.private.accounts
