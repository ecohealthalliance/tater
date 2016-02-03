Package.describe({
  name: 'tater:styles',
  version: '0.0.1',
  summary: 'Styles for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('twbs:bootstrap@3.3.4');
  api.use('useraccounts:bootstrap');
  api.use('mquandalle:stylus');
  api.use('fortawesome:fontawesome');

  api.addFiles('variables.import.styl');
  api.addFiles('mixins.import.styl');
  api.addFiles('extends.import.styl');
  api.addFiles('globals.import.styl');

  api.addFiles('layout.import.styl');
  api.addFiles('tables.import.styl');
  api.addFiles('lists.import.styl');
  api.addFiles('modals.import.styl');
  api.addFiles('forms.import.styl');
  api.addFiles('header.import.styl');
  api.addFiles('footer.import.styl');

  api.addFiles('splash_page.import.styl');
  api.addFiles('marketing_page.import.styl');
  api.addFiles('register.import.styl');

  api.addFiles('help.import.styl');
  api.addFiles('admin.import.styl');
  api.addFiles('accounts.import.styl');
  api.addFiles('profile.import.styl');
  api.addFiles('groups.import.styl');
  api.addFiles('documents.import.styl');
  api.addFiles('document_detail.import.styl');
  api.addFiles('coding_keywords.import.styl');
  api.addFiles('annotations.import.styl');
  api.addFiles('eula.import.styl');

  api.addFiles('velocity.import.styl');
  api.addFiles('mturk.import.styl');

  api.addFiles('main.styl');
});
