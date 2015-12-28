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
    password:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(8, 'The password must be at least 8 characters')
        Validators.equalTo('passwordCheck', 'Password and confirmation password do not match')
      ]
    passwordCheck:
      type: 'string'
    orgName:
      type: 'string'
    tenantName:
      type: 'string'
      validator: [
        Validators.required()
        Validators.unique()
      ]
  behaviors: ['timestamp']
