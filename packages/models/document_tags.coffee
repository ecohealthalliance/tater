DocumentTags = new Mongo.Collection('documentTags')
DocumentTag = Astro.Class
  name: 'DocumentTag'
  collection: DocumentTags
  transform: true
  fields:
    documentId: 'string'
    userId: 'string'
    tag: 'string'
