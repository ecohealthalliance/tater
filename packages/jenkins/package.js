Package.describe({
  name: 'tater:jenkins',
  version: '0.0.1',
  summary: 'Wrapper for jenkins',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('http');
  api.use('peerlibrary:xml2js');
  api.addFiles('jenkins.coffee', 'server');
  api.export('Jenkins', 'server');
});
