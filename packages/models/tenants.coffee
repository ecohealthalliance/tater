Tenants = new Mongo.Collection('tenants')
Tenant = Astro.Class
  name: 'Tenant'
  collection: Tenants
  fields:
    fullName: 'string'
    emailAddress: 'string'
    password: 'string'
    orgName: 'string'
    tenantName: 'string'
  behaviors: ['timestamp']
