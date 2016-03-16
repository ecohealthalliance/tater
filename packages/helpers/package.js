Package.describe({
  name: 'tater:helpers',
  version: '0.0.1',
  summary: 'Helpers for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('tater:models');
  api.addFiles('tenant_helper.coffee', ['server']);
  api.addFiles('error_helper.coffee', ['client']);
  api.export('TenantHelpers', ['server']);
  api.export('ErrorHelpers', ['client']);
});
