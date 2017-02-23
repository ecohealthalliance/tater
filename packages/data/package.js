Package.describe({
  name:    'tater:data',
  version: '0.0.2',
  summary: 'Database seed methods for tater'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.addFiles('postMessageHandler.coffee', 'client')
  api.addFiles([
    'default_codes.coffee',
    'database_seeds.coffee',
    'bsve_codes.coffee',
    'bsve_init.coffee'
  ], 'server');
});
