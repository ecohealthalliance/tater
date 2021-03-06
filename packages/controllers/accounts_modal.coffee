AccountsTemplates.configure
  showPlaceholders: false
  enablePasswordChange: true
  hideSignUpLink: true
  showForgotPasswordLink: true
  onSubmitHook: (err, state)->
    unless err
      $('.accounts-modal').modal('hide')
      $('.accounts-modal').off('hidden.bs.modal')
      # sign in fields are cleared so they don't remain populated after a logout
      $('.accounts-modal input').val('')
      if state is 'changePwd'
        toastr.success("Success")
        setTimeout(->
          AccountsTemplates.clearResult()
        , 0)

Template.accountsModal.onCreated ->
  @state = Template.currentData()?.state

Template.accountsModal.onRendered ->
  $('.accounts-modal').on 'hidden.bs.modal', ->
    AccountsTemplates.state.form.set('error', '')

Template.accountsModal.helpers
  state: -> Template.instance().state.get()

Template.accountsModal.events
  'click #at-signUp' : (evt, instance)->
    instance.state.set("signUp")
  'click #at-signIn' : (evt, instance)->
    instance.state.set("signIn")
  'click #at-forgotPwd' : (evt, instance)->
    instance.state.set("forgotPwd")
