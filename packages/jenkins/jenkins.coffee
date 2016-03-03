class Jenkins
  constructor: (attributes) ->
    @jenkinsUrl = attributes.jenkinsUrl
    @user = attributes.user
    @key = attributes.key

  authenticatedUrl: ->
    "https://#{@user}:#{@key}@#{@jenkinsUrl}"

  getCrumb: (callback) ->
    url = "#{@authenticatedUrl()}/crumbIssuer/api/xml"
    console.log(url)
    request.get url, {rejectUnauthorized: false}, (error, response) ->
      crumb = xml2js.parseString response.body, (error, response) ->
        callback(response.defaultCrumbIssuer)

  triggerBuildWithParameters: (jobName, jobToken, parameters) ->
    @getCrumb (crumbIssuer) =>
      crumbValue = crumbIssuer.crumb[0]
      crumbField = crumbIssuer.crumbRequestField[0]

      url = "#{@authenticatedUrl()}/job/#{jobName}/buildWithParameters?token=#{jobToken}"
      for key, value of parameters
        url += "&#{key}=#{value}"

      request.post url, {rejectUnauthorized: false, headers: {"#{crumbField}": crumbValue}}, (error, response) ->
        console.log(error)
        console.log(response)
