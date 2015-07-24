Package.describe({
  name: 'tater:views',
  version: '0.0.1',
  summary: 'Views for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('templating');
  api.use('mquandalle:jade@0.4.1');
  api.use('tater:styles');
  api.use('tater:accounts');
  api.use('tater:route-helpers');
  api.use('aslagle:reactive-table');

  api.addFiles('accounts_modal.jade');
  api.addFiles('accounts_header_buttons.jade')
  api.addFiles('splash_page.jade', 'client');
  api.addFiles('profile_edit.jade', 'client');
  api.addFiles('profile_detail.jade', 'client');
  api.addFiles('groups.jade', 'client');
  api.addFiles('group_form.jade', 'client');
  api.addFiles('user_table.jade', 'client');
  api.addFiles('user_form.jade', 'client');
  api.addFiles('group_detail.jade', 'client');
  api.addFiles('group_documents.jade', 'client');
  api.addFiles('document_form.jade', 'client');
  api.addFiles('header.jade', 'client');
  api.addFiles('footer.jade', 'client');
  api.addFiles('layout.jade', 'client');
  api.addFiles('paragraph_text.jade', 'client');
  api.addFiles('documents.jade', 'client');
});
