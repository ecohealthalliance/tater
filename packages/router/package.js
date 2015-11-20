Package.describe({
  name: 'tater:router',
  version: '0.0.1',
  summary: 'Routing for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('templating');
  api.use('meteorhacks:flow-layout@1.3.0');
  api.use('meteorhacks:flow-router@1.9.0');
  api.use('nimble:restivus');
  
  api.use('tater:controllers');
  
  api.addFiles('router.coffee', ['client', 'server']);

});
