if Meteor.isClient
  Template.register.onCreated ->
    @registering = new ReactiveVar(true)

  Template.register.onRendered ->
    $('.content-wrap').addClass('no-margin-padding')

  Template.register.helpers
    registering : ->
      Template.instance().registering.get()

  Template.register.events
    'input .tenant-name': (event, template) ->
      target = event.target
      name = target.value.replace /[^a-zA-Z0-9-]$/, ''
      $(target).val(name)

    'submit #tenant-registration': (event, template) ->
      event.preventDefault()
      form = event.target
      tenantProps =
        fullName: form.fullName.value
        emailAddress: form.emailAddress.value
        orgName: form.orgName.value
        tenantName: form.tenantName.value.toLowerCase()

      creditCardProps =
        number: $('[data-stripe="cardNumber"]').val()
        cvc: $('[data-stripe="cvc"]').val()
        exp_month: parseInt($('[data-stripe="expirationMonth"]').val())
        exp_year: parseInt($('[data-stripe="expirationYear"]').val())

      Stripe.card.createToken creditCardProps, (status, response) ->
        if response.error
          toastr.error(response.error.message)
        else
          tenantProps.stripeToken = response.id
          Meteor.call 'registerTenant', tenantProps, (error, response) ->
            if error
              if error.reason
                for key, reason of error.reason
                  toastr.error("Error: #{reason}")
              else
                toastr.error("Error: #{error.error}")
            else
              template.registering.set(false)

if Meteor.isServer
  Meteor.methods
    'registerTenant': (tenantProps) ->
        tenant = new Tenant()
        tenant.set(tenantProps)
        if tenant.validate()
          tenant.save()
          # Email to EHA
          Email.send
            to: 'tater-beta@ecohealthalliance.org'
            from: 'no-reply@tater.io'
            subject: 'Tater beta user registration'
            text: """
              #{tenantProps.fullName} has registered for Tater!
              Tenant Name: #{tenantProps.tenantName}
              Tenant Email: #{tenantProps.emailAddress}
              Organization Name: #{tenantProps.orgName}
              """
          # Email to future tenant
          Email.send
            to: tenantProps.emailAddress
            from: 'no-reply@tater.io'
            subject: 'Thanks for registering as a Tater beta user'
            text: """
              Thanks for registering as a beta user for Tater.
              We will be in touch as soon as we set up your instance of Tater
              If you have any questions, please email us at tater-beta@ecohealthalliance.org.
              """
        else
          tenant.throwValidationException()
