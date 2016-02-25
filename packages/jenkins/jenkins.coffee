class Jenkins
  constructor: (attributes) ->
    @jenkinsUrl = attributes.jenkinsUrl
    @user = attributes.user
    @key = attributes.key

  authenticatedUrl: ->
    "http://#{@user}:#{@key}@#{@jenkinsUrl}"

  getCrumb: (callback) ->
    url = "#{@authenticatedUrl()}/crumbIssuer/api/xml"
    request.get url, {}, (error, response) ->
      crumb = xml2js.parseString response.body, (error, response) ->
        callback(response.defaultCrumbIssuer)

  triggerBuildWithParameters: (jobName, jobToken, parameters) ->
    @getCrumb (crumbIssuer) =>
      crumbValue = crumbIssuer.crumb[0]
      crumbField = crumbIssuer.crumbRequestField[0]

      url = "#{@authenticatedUrl()}/job/#{jobName}/buildWithParameters?token=#{jobToken}"
      for key, value of parameters
        url += "&#{key}=#{value}"

      request.post url, {headers: {"#{crumbField}": crumbValue}}, (error, response) ->
        console.log(error)
        console.log(response)
