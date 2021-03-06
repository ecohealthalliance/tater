Package.describe({
  name: 'tater:accounts',
  version: '0.0.1',
  summary: 'Accounts for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use(['coffeescript', 'ui']);
  api.use('accounts-ui');
  api.use('aslagle:reactive-table');
  api.addFiles('user_publications.coffee', ['server', 'client']);
  api.addFiles('admin_helper.coffee', ['client']);
  api.addFiles('default_user.coffee', ['server']);
  api.addFiles('custom_methods.coffee', ['server', 'client']);
  api.addFiles('presence.coffee', ['server', 'client']);
});
