if Meteor.isClient
  UI.registerHelper 'isAdmin', () ->
    Meteor.user()?.admin

  UI.registerHelper 'onBSVEInstance', () ->
    Boolean(_.findWhere(Meteor.user()?.emails or [], {
      address: Meteor.settings.public.accounts.tokenUser
    }))
