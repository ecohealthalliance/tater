var jenkins = new Jenkins({
  'jenkinsUrl': "jenkins.test.com",
  'user': "testuser",
  'key': "password"
});

Tinytest.add('#authenticatedUrl - adds user and key to url', function (test) {
  var expectedUrl = "http://testuser:password@jenkins.test.com"
  test.equal(jenkins.authenticatedUrl, expectedUrl)
});

Tinytest.add('#authenticatedUrl - uses https if specified', function (test) {
  var jenkinsHttps = new Jenkins({
    'jenkinsUrl': "jenkins.test.com",
    'user': "testuser",
    'key': "password",
    'https': true
  });
  var expectedUrl = "https://testuser:password@jenkins.test.com"
  test.equal(jenkinsHttps.authenticatedUrl, expectedUrl)
});

Tinytest.add('#buildPath - constructs the build endpoint', function (test) {
  var expectedPath = "/job/testJob/build?token=testToken"
  var realPath = jenkins.buildPath('testJob', 'testToken');
  test.equal(realPath, expectedPath)
});

Tinytest.add('#buildPath - adds parameters if they given', function (test) {
  var expectedPath = "/job/testJob/buildWithParameters?token=testToken&a=1&b=2"
  var realPath = jenkins.buildPath('testJob', 'testToken',
                                   {'a': '1', 'b': '2'});
  test.equal(realPath, expectedPath)
});

Tinytest.add('#postToUrl - posts to the given url', function (test) {
  var gotCrumb = false;
  request.getSync = function(url, headers) {
    test.equal(url, jenkins.authenticatedUrl+"/crumbIssuer/api/xml");
    gotCrumb = true;
    return {'body': "<defaultCrumbIssuer><crumb>testCrumb</crumb>\
      <crumbRequestField>.crumb</crumbRequestField></defaultCrumbIssuer>"}
  };

  var hitPostEndpoint = false;
  request.post = function(url, headers) {
    test.equal(url, 'someTestUrl');
    hitPostEndpoint = true;
  };

  jenkins.postToUrl('someTestUrl');
  test.equal(gotCrumb, true);
  test.equal(hitPostEndpoint, true);
});

Tinytest.add('#triggerBuild - calls #postToUrl', function (test) {
  var expectedUrl = "http://testuser:password@jenkins.test.com"
    + "/job/testJob/build?token=testToken"

  var calledPostToUrl = false;
  jenkins.postToUrl = function(url, headers) {
    test.equal(url, expectedUrl);
    calledPostToUrl = true;
  };

  jenkins.triggerBuild('testJob', 'testToken');
  test.equal(calledPostToUrl, true);
});

Tinytest.add('#triggerBuildWithParameters - calls #postToUrl', function (test) {
  var expectedUrl = "http://testuser:password@jenkins.test.com"
    + "/job/testJob/buildWithParameters?token=testToken&a=1&b=2"

  var calledPostToUrl = false;
  jenkins.postToUrl = function(url, headers) {
    test.equal(url, expectedUrl);
    calledPostToUrl = true;
  };

  jenkins.triggerBuildWithParameters('testJob', 'testToken',
                                     {'a': '1', 'b': '2'});
  test.equal(calledPostToUrl, true);
});
