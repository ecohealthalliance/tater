Documents = new Mongo.Collection('documents')
Document = Astro.Class
  name: 'Document'
  collection: Documents
  transform: true
  fields:
    title: 'string'
    body: 'string'
    groupId: 'string'
