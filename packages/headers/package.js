Package.describe({
  name: 'tater:headers',
  version: '0.0.1',
  summary: 'Additional HTTP headers for Tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.addFiles('http.coffee', ['server']);
});
