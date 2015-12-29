Tenants = new Mongo.Collection('tenants')
Tenant = Astro.Class
  name: 'Tenant'
  collection: Tenants
  fields:
    fullName:
      type: 'string'
      validator: [
        Validators.required()
      ]
    emailAddress:
      type: 'string'
      validator: [
        Validators.required()
        Validators.regexp(/^.+@.+\..+$/, 'Please enter a valid email address')
      ]
    orgName:
      type: 'string'
    tenantName:
      type: 'string'
      validator: [
        Validators.required()
        Validators.unique()
        Validators.regexp(/^[a-zA-Z0-9-]+$/, "Your Tater URL can only contain letters, numbers and '-'")
      ]
  behaviors: ['timestamp']
