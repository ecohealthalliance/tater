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
  api.use('tater:query-helpers');
  api.use('tater:helpers');
  api.use('tater:string-helpers');
  api.use('accounts-password');
  api.use('useraccounts:core');
  api.use('chrismbeckett:toastr');
  api.use('aslagle:reactive-table');
  api.use('mrt:jquery-easing');
  api.use('harrison:babyparse');
  api.use('alethes:pages@1.8.4');
  api.use('mrgalaxy:stripe@2.2.1');
  api.use('email');
  api.addFiles('admin.coffee', ['client', 'server']);
  api.addFiles('delete_document_modal.coffee', ['client', 'server']);
  api.addFiles('delete_keyword_modal.coffee', ['client', 'server']);
  api.addFiles('delete_subheader_modal.coffee', ['client', 'server']);
  api.addFiles('delete_header_modal.coffee', ['client', 'server']);
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
  api.addFiles('user_modal.coffee', ['client', 'server']);
  api.addFiles('users.coffee', ['client', 'server']);
  api.addFiles('group_documents.coffee', ['client', 'server']);
  api.addFiles('document.coffee', ['client', 'server']);
  api.addFiles('document_form.coffee', ['client', 'server']);
  api.addFiles('document_list.coffee', ['client', 'server']);
  api.addFiles('annotations_coding_keywords.coffee', ['client', 'server']);
  api.addFiles('coding_keywords.coffee', ['client', 'server']);
  api.addFiles('document_detail_coding_keywords.coffee', ['client', 'server']);
  api.addFiles('edit_coding_keywords.coffee', ['client', 'server']);
  api.addFiles('annotations.coffee', ['client', 'server']);
  api.addFiles('random_document.coffee', ['client', 'server']);
  api.addFiles('splash_page.coffee', ['client', 'server']);
  api.addFiles('reset_password.coffee', ['client', 'server']);
  api.addFiles('enroll_account.coffee', ['client', 'server']);
  api.addFiles('help.coffee', ['client']);
  api.addFiles('register.coffee', ['client', 'server']);
  api.addFiles('eula.coffee', ['client', 'server']);
  api.addFiles('tooltip_icon.coffee', ['client', 'server']);
  api.addFiles('create_mturk_job_modal.coffee', ['client', 'server']);
  api.addFiles('stripe.coffee', 'client');
  api.addFiles('connection_status.coffee', ['client', 'server']);
  api.addFiles('password_field.coffee', 'client');
});
