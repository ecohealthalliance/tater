Package.describe({
  name: 'tater:string-helpers',
  version: '0.0.1',
  summary: 'String helpers for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.addFiles('string_helpers.coffee', ['client', 'server']);
  api.export('StringHelpers', ['client', 'server']);
});
