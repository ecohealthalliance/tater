if Meteor.isClient
  Template.header.onCreated ->
    @accountsState = new ReactiveVar("signIn")

  Template.header.helpers
    accountsState: -> Template.instance().accountsState

    usingAccessCode: ->
      window.location.search.match('generateCode=')

    documentsLinkParams: ->
      { _id: Meteor.user().group }

  Template.header.events
    'click a' : (e) ->
      if $('.navbar-toggle').is(':visible') and $('.navbar-collapse').hasClass('in') and !$(e.currentTarget).hasClass('dropdown-toggle')
        $('.navbar-collapse').collapse('toggle')
    'click .sign-in' : (evt, instance) ->
      instance.accountsState.set("signIn")
      $('.accounts-modal').modal('show')
