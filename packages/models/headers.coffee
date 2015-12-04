Headers = new Mongo.Collection('headers')
Headers = Astro.Class
  name: 'Headers'
  collection: Headers
  fields:
    color: 'number'
    label: 'string'
    archived: 'boolean'
  behaviors: ['timestamp']
