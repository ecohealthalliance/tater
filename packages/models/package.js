Package.describe({
  name: 'tater:models',
  version: '0.0.1',
  summary: 'Models for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('jagi:astronomy');
  api.use('accounts-password');
  api.use('useraccounts:core@1.7.0');
  api.use('mongo');
  api.addFiles('user_profiles.coffee', ['client', 'server']);
  api.addFiles('groups.coffee', ['client', 'server']);
  api.addFiles('documents.coffee', ['client', 'server']);
  api.addFiles('coding_keywords.coffee', 'client');
  api.export(['UserProfile', 'UserProfiles'], ['client', 'server']);
  api.export(['Group', 'Groups'], ['client', 'server']);
  api.export(['Document', 'Documents'], ['client', 'server']);
  api.export(['CodingKeywords'], 'client');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('coffeescript');
  api.use('tater:models');
  api.use('practicalmeteor:munit');
  api.use('test-helpers');
  api.addFiles('tests/server/user_profiles_test.coffee', 'server');
  api.addFiles('tests/server/groups_test.coffee', 'server');
  api.addFiles('tests/server/documents_test.coffee', 'server');
});
