Package.describe({
  name: 'tater:server-router',
  version: '0.0.1',
  summary: 'Server-side routing for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('meteorhacks:picker');
  api.addFiles('router.coffee', ['server']);
});
