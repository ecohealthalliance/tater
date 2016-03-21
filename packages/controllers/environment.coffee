#Some 3rd party packages force you to use environment vars :(

Meteor.startup ->
  if Meteor.settings.private?.MAIL_URL
    try process.env.MAIL_URL = Meteor.settings.private.MAIL_URL
    catch e then console.log e
