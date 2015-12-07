SubHeaders = new Mongo.Collection('subHeaders')
SubHeaders = Astro.Class
  name: 'SubHeaders'
  collection: SubHeaders
  fields:
    headerId: 'string'
    label: 'string'
    archived: 'boolean'
  behaviors: ['timestamp']
