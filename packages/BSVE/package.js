Package.describe({
  name:    'tater:BSVE',
  version: '0.0.1',
  summary: 'BSVE related code'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.addFiles('postMessageHandler.coffee');
});
