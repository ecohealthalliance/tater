if Meteor.isServer

  Meteor.startup ->

    secureHeaders = (req, res, next) ->
      # Enforce HTTP Strict Transport Security to prevent MiTM-style attacks
      res.setHeader 'Strict-Transport-Security', 'max-age=2592000; includeSubDomains'
      # Prevent MIME-type based attacks
      res.setHeader 'X-Content-Type-Options', 'nosniff'
      next()

    # Additional HTTP headers for static assets
    WebApp.rawConnectHandlers.use secureHeaders
