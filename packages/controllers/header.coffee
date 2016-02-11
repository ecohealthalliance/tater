if Meteor.isClient

  Template.header.onCreated ->
    @accountsState = new ReactiveVar "signIn"

  Template.header.helpers
    accountsState: -> Template.instance().accountsState

    documentsLinkParams: ->
      _id: Meteor.user().group

  Template.header.events
    'click .nav a' : (event) ->
      if $('.navbar-toggle').is(':visible') and
         $('.navbar-collapse').hasClass('in') and
         not $(event.currentTarget).hasClass('dropdown-toggle')
        $('.navbar-collapse').collapse('toggle')

    'click .sign-in' : (event, instance) ->
      AccountsTemplates.setState('signIn')
      instance.accountsState.set("signIn")
      $('.accounts-modal').modal('show')
