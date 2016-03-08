class Jenkins
  constructor: (attributes={}) ->
    @jenkinsUrl = attributes.jenkinsUrl if attributes.jenkinsUrl?
    @user = attributes.user if attributes.user?
    @key = attributes.key if attributes.key?

    protocol = if attributes.https? then "https" else "http"
    @authenticatedUrl = "#{protocol}://#{@user}:#{@key}@#{@jenkinsUrl}"

  buildPath: (jobName, jobToken, parameters) ->
    withParameters = if parameters then "WithParameters" else ""
    path = "/job/#{jobName}/build#{withParameters}?token=#{jobToken}"
    for key, value of parameters
      path += "&#{key}=#{value}"
    path

  postToUrl: (url) ->
    @_getCrumb (crumbIssuer) =>
      crumbValue = crumbIssuer.crumb[0]
      crumbField = crumbIssuer.crumbRequestField[0]

      request.post url, {rejectUnauthorized: false, headers: {"#{crumbField}": crumbValue}}

  triggerBuild: (jobName, jobToken, parameters) ->
    url = "#{@authenticatedUrl}#{@buildPath(jobName, jobToken, parameters)}"
    @postToUrl(url)

  triggerBuildWithParameters: (jobName, jobToken, parameters) ->
    url = "#{@authenticatedUrl}#{@buildPath(jobName, jobToken, parameters)}"
    @postToUrl(url)

  _getCrumb: (callback) ->
    url = "#{@authenticatedUrl}/crumbIssuer/api/xml"
    crumbXml = request.getSync url, {rejectUnauthorized: false}
    xml2js.parseString crumbXml.body, (error, response) ->
      callback(response.defaultCrumbIssuer)
