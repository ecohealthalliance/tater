Meteor.startup ->
  hasUsers = Meteor.users.find().count() > 0

  Meteor.methods
    seed: (newTenantData) ->
      unless hasUsers || process.env.ALLOW_TOKEN_ACCESS
        createDefaultTenant = (tenantFields) ->
          check tenantFields, Object
          check tenantFields.emailAddress, String
          tenant = new Tenant(
            fullName: tenantFields.fullName
            emailAddress: tenantFields.emailAddress
            orgName: tenantFields.orgName
            tenantName: tenantFields.tenantName
            stripeCustomerId: tenantFields.stripeCustomerId
            current: true
          )
          tenant.save()
          tenant

        createDefaultUser = (email) ->
          newUserId = Accounts.createUser
            email: email
            admin: true
          Accounts.sendEnrollmentEmail(newUserId)

        createDefaultCodes = (headerLabel, subHeaderLabel, keywordLabel) ->
          if Headers.find().count() == 0
            headerId = Headers.insert
              label: headerLabel or 'Header'
              color: 1
            subHeaderId = SubHeaders.insert
              headerId: headerId
              label: subHeaderLabel or 'Sub-Header'
            CodingKeywords.insert
              subHeaderId: subHeaderId
              label: keywordLabel or 'Keyword'
          else
            throw new Meteor.Error 'invalid', 'Already have codes in the database'

        seedDatabase = (newTenantFields) ->
          tenant = createDefaultTenant(newTenantFields)
          createDefaultUser(tenant.emailAddress)
          createDefaultCodes()

        seedDatabase(newTenantData)
      else
        throw new Meteor.Error 'unauthorized', 'Not allowed to perform the operation'
