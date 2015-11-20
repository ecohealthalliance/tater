Package.describe({
  name: 'tater:api',
  version: '0.0.1',
  summary: 'API for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('templating');
  api.use('meteorhacks:flow-layout@1.3.0');
  api.use('meteorhacks:flow-router@1.9.0');
  api.use('nimble:restivus');
  
  api.addFiles('api.coffee', ['server']);

});
