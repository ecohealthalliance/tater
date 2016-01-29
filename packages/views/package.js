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
  api.use('visudare:retina');

  api.addFiles('delete_document_modal.jade');
  api.addFiles('delete_keyword_modal.jade');
  api.addFiles('delete_subheader_modal.jade');
  api.addFiles('delete_header_modal.jade');
  api.addFiles('accounts_modal.jade');
  api.addFiles('accounts_header_buttons.jade');
  api.addFiles('splash_page.jade', 'client');
  api.addFiles('profile_edit.jade', 'client');
  api.addFiles('profile_detail.jade', 'client');
  api.addFiles('admin.jade', 'client');
  api.addFiles('groups.jade', 'client');
  api.addFiles('group_form.jade', 'client');
  api.addFiles('users.jade', 'client');
  api.addFiles('user_form.jade', 'client');
  api.addFiles('user_modal.jade', 'client');
  api.addFiles('group_detail.jade', 'client');
  api.addFiles('group_documents.jade', 'client');
  api.addFiles('document_form.jade', 'client');
  api.addFiles('document_detail.jade', 'client');
  api.addFiles('document_list.jade', 'client');
  api.addFiles('annotation_form.jade', 'client');
  api.addFiles('paragraph_text.jade', 'client');
  api.addFiles('header.jade', 'client');
  api.addFiles('footer.jade', 'client');
  api.addFiles('layout.jade', 'client');
  api.addFiles('documents.jade', 'client');
  api.addFiles('annotations_coding_keywords.jade', 'client');
  api.addFiles('coding_keywords.jade', 'client');
  api.addFiles('edit_coding_keywords.jade', 'client');
  api.addFiles('annotations.jade', 'client');
  api.addFiles('random_document.jade', 'client');
  api.addFiles('document_new.jade', 'client');
  api.addFiles('marketing_page.jade', 'client');
  api.addFiles('reset_password.jade', 'client');
  api.addFiles('enroll_account.jade', 'client');
  api.addFiles('document_detail_coding_keywords.jade', 'client');
  api.addFiles('help.jade', 'client');
  api.addFiles('register.jade', 'client');
  api.addFiles('eula.jade', 'client');
  api.addFiles('tooltip_icon.jade', 'client');
  api.addFiles('create_mturk_job_modal.jade', 'client');
  api.addFiles('connection_status.jade', ['client']);
});
