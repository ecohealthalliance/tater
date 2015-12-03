Headers = new Mongo.Collection('headers')
Headers = Astro.Class
  name: 'Headers'
  collection: Headers
  fields:
    color: 'string'
    label: 'string'
  behaviors: ['timestamp']
