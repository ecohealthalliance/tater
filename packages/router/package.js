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
  api.use('kadira:blaze-layout');
  api.use('kadira:flow-router@2.10.0');
  api.use('tater:controllers');
  api.use('zimme:active-route');
  api.addFiles('router.coffee', ['client', 'server']);
});
