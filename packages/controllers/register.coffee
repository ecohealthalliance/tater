if Meteor.isClient
  Template.register.onCreated ->
    @registering = new ReactiveVar(true)

  Template.register.onRendered ->
    $('.content-wrap').addClass('no-margin-padding')
    $('.page-wrap').addClass('register-wrap')

  Template.register.helpers
    registering : ->
      Template.instance().registering.get()

    expirationYear : ->
      currentDate = new Date()
      currentYear = currentDate.getUTCFullYear()
      yearOptions = []
      _.each _.range(11), (index) ->
        yearOptions.push(currentYear + index)
      yearOptions

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
        number: template.$('[data-stripe="cardNumber"]').val().trim()
        cvc: template.$('[data-stripe="cvc"]').val().trim()
        exp_month: parseInt(template.$('[data-stripe="expirationMonth"]').val().trim())
        exp_year: parseInt(template.$('[data-stripe="expirationYear"]').val().trim())
        address_zip: template.$('[data-stripe="addressZip"]').val().trim()

      Stripe.card.createToken creditCardProps, (status, response) ->
        if response.error
          toastr.error(response.error.message)
        else
          Meteor.call 'createStripeCustomer', response.id, tenantProps.emailAddress, (error, response) ->
            tenantProps.stripeCustomerId = response.id
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
    'createStripeCustomer': (token, email) ->
      Future = Npm.require('fibers/future')
      secret = Meteor.settings.private.stripe.secretKey
      StripeServer = StripeAPI(secret)
      stripeCustomer = new Future()
      StripeServer.customers.create {card: token, email: email}, (error, result) ->
        if error
          stripeCustomer.return(error)
        else
          stripeCustomer.return(result)
      stripeCustomer.wait()

    'registerTenant': (tenantProps) ->
        tenant = new Tenant()
        tenant.set(tenantProps)
        if tenant.validate()
          tenant.save()
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
