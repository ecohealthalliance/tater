if Meteor.isClient
  Template.register.onCreated ->
    @registering = new ReactiveVar(true)

  Template.register.helpers
    registering : ->
      Template.instance().registering.get()

  Template.register.events
    'submit #tenant-registration': (event, template) ->
      event.preventDefault()
      form = event.target
      tenantProps =
        fullName: form.fullName.value
        emailAddress: form.emailAddress.value
        password: form.password.value
        orgName: form.orgName.value
        tenantName: form.tenantName.value

      Meteor.call 'registerTenant', tenantProps, (error, response) ->
        if error
          if error.reason
            for key, reason of error.reason
              toastr.error("Error: #{reason}")
          else
            toastr.error("Error: #{error.error}")
        else
          toastr.success("Tenant Registration Complete")
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
            from: tenantProps.emailAddress
            subject: 'Tater beta user registration'
            text: """
              #{tenantProps.fullName} has registered for Tater!
              Tenant Name: #{tenantProps.tenantName}
              """
          # Email to future tenant
          Email.send
            to: tenantProps.emailAddress
            from: 'tater-beta@ecohealthalliance.org'
            subject: 'Thanks for registering as a Tater beta user'
            text: """
              Thanks for registering as a beta user for Tater.
              We will be in touch as soon as we set up your instance of Tater
              If you have any questions, please email us at tater-beta@ecohealthalliance.org.
              """
        else
          tenant.throwValidationException()
