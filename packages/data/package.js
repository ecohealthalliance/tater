Package.describe({
  name: 'tater:data',
  version: '0.0.1',
  summary: 'Database methods for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use(['coffeescript']);
  api.addFiles('default_codes.coffee', ['server', 'client']);
  api.addFiles('bsve_init.coffee', ['server']);
});
