#Some 3rd party packages force you to use environment vars :(
Meteor.startup ->
  process.env.MAIL_URL = Meteor.settings.private.MAIL_URL

