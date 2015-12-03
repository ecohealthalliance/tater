Package.describe({
  name: 'tater:route-helpers',
  version: '0.0.1',
  summary: 'Utility for generating URL paths',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('templating');
  api.use('kadira:flow-router');

  api.addFiles('helpers.coffee', 'client');
  api.export('go', 'client');
  api.export('reloadPage', 'client');
});


