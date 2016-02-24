Package.describe({
  name:    'tater:data',
  version: '0.0.1',
  summary: 'Database seed methods for tater'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.addFiles(['database_seeds.coffee', 'bsve_init.coffee'], 'server');
});
