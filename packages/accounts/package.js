Package.describe({
  name: 'tater:accounts',
  version: '0.0.1',
  summary: 'Accounts for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.addFiles('user_publications.coffee', ['server']);
});
