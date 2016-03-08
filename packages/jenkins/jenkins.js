Jenkins = (function() {
  function Jenkins(attributes) {
    this.jenkinsUrl = attributes.jenkinsUrl;
    this.user = attributes.user;
    this.key = attributes.key;

    protocol = attributes.https ? "https" : "http";
    this.authenticatedUrl = protocol+"://"+this.user+":"+this.key
      +"@"+this.jenkinsUrl;

    this.buildPath = function(jobName, jobToken, parameters) {
      var withParameters = parameters ? "WithParameters" : ""
      var path = "/job/"+jobName+"/build"+withParameters+"?token="+jobToken
      for(var key in parameters) {
        var value = parameters[key]
        path += "&"+key+"="+value
      }
      return path;
    };

    this.postToUrl = function(url) {
      this._getCrumb(function(crumbIssuer) {
        var crumbValue = crumbIssuer.crumb[0]
        var crumbField = crumbIssuer.crumbRequestField[0]
        var headers = {};
        headers[crumbField] = crumbValue;

        request.post(url, {'rejectUnauthorized': false, 'headers': headers})
      });
    };

    this._getCrumb = function(callback) {
      var url = this.authenticatedUrl+"/crumbIssuer/api/xml";
      var crumbXml = request.getSync(url, {'rejectUnauthorized': false})
      xml2js.parseString(crumbXml.body, function(error, response) {
        callback(response.defaultCrumbIssuer);
      });
    };

    this.triggerBuild = function(jobName, jobToken) {
      var url = this.authenticatedUrl+this.buildPath(jobName, jobToken);
      this.postToUrl(url);
    };

    this.triggerBuildWithParameters = function(jobName, jobToken, parameters) {
      var url = this.authenticatedUrl+this.buildPath(jobName, jobToken, parameters);
      this.postToUrl(url);
    };
  }

  return Jenkins;
})();
