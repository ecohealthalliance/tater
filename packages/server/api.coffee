  # Listen to incoming HTTP requests, can only be used on the server
  WebApp.connectHandlers.use '/public', (req, res, next) ->
    res.setHeader 'Access-Control-Allow-Origin', '*'
    next()