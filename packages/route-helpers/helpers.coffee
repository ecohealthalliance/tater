Template.registerHelper 'path', (kwArgs) ->
  route = kwArgs.hash.route
  params = kwArgs.hash.params
  query = kwArgs.hash.query
  FlowRouter.path route, params, query

go = (route, params, query) ->
  FlowRouter.go route, params, query

path = (route, params, query) ->
  FlowRouter.go route, params, query

reloadPage = ->
  FlowRouter.reload()
