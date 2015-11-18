Package.describe({
  name: 'tater:query-helpers',
  version: '0.0.1',
  summary: 'Helpers for creating mongo queries.',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('tater:models');
  api.addFiles('query_helpers.coffee', ['client', 'server']);
  api.export('QueryHelpers', ['client', 'server']);
});
