@colorLoop = (currentColor) -> if currentColor > 7 then 1 else ++currentColor

Meteor.startup ->
  hasUsers = Meteor.users.find().count() > 0

  Meteor.methods
    seed: (newTenantData) ->
      if !hasUsers and !process.env.ALLOW_TOKEN_ACCESS
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
          unless Headers.find().count()
            colorId = 0
            for H, Header of initialData
              colorId = colorLoop(colorId++)
              headerId = Headers.insert
                label: H
                color: colorId
              for SH, SubHeader of Header
                subHeaderId = SubHeaders.insert
                  headerId: headerId
                  label: SH
                for Keyword in SubHeader
                  CodingKeywords.insert
                    subHeaderId: subHeaderId
                    label: Keyword
          else
            throw new Meteor.Error 'invalid', 'Already have codes in the database'

        seedDatabase = (newTenantFields) ->
          tenant = createDefaultTenant(newTenantFields)
          createDefaultUser(tenant.emailAddress)
          createDefaultCodes()

        seedDatabase(newTenantData)
      else
        throw new Meteor.Error 'unauthorized', 'Not allowed to perform the operation'
