Package.describe({
  name: 'tater:controllers',
  version: '0.0.1',
  summary: 'Controllers for tater',
  git: ''
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('underscore');
  api.use('templating');
  api.use('reactive-var');
  api.use('tater:models');
  api.use('tater:views');
  api.use('tater:accounts');
  api.use('tater:route-helpers');
  api.use('accounts-password');
  api.use('useraccounts:core');
  api.use('chrismbeckett:toastr');
  api.use('aslagle:reactive-table');
  api.use('mrt:jquery-easing');

  api.addFiles('toastr.coffee', 'client');
  api.addFiles('header.coffee', 'client');
  api.addFiles('accounts_modal.coffee', 'client');
  api.addFiles('accounts_header_buttons.coffee', ['client', 'server']);
  api.addFiles('profile_edit.coffee', ['client', 'server']);
  api.addFiles('profile_detail.coffee', ['client', 'server']);
  api.addFiles('groups.coffee', ['client', 'server']);
  api.addFiles('group_form.coffee', ['client', 'server']);
  api.addFiles('group_detail.coffee', ['client', 'server']);
  api.addFiles('document_detail.coffee', ['client', 'server']);
  api.addFiles('paragraph_text.coffee', ['client']);
  api.addFiles('user_form.coffee', ['client', 'server']);
  api.addFiles('users.coffee', ['client', 'server']);
  api.addFiles('group_documents.coffee', ['client', 'server']);
  api.addFiles('document_form.coffee', ['client', 'server']);
  api.addFiles('documents.coffee', ['client', 'server']);
  api.addFiles('user_form.coffee', 'client');
  api.addFiles('coding_keywords.coffee', ['client', 'server']);
  api.addFiles('document_detail_coding_keywords.coffee', ['client', 'server']);
  api.addFiles('edit_coding_keywords.coffee', ['client', 'server']);
  api.addFiles('annotations.coffee', ['client', 'server']);
  api.addFiles('random_document.coffee', ['client', 'server']);
  api.addFiles('reset_password.coffee', ['client', 'server']);
});
